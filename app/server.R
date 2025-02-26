#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
###############################Install Related Packages #######################
if (!require("dtplyr")) install.packages('dtplyr')
if (!require("dtplyr")) install.packages('dtplyr')
if (!require("shiny")) install.packages("shiny")
if (!require("shinydashboard")) install.packages("shinydashboard")
if (!require("leaflet")) install.packages("leaflet")
if (!require("scales")) install.packages("scales")
if (!require("forecast")) install.packages("forecast")
if (!require("leaflet.extras")) install.packages("leaflet.extras")

library(dtplyr)
library(dplyr)
library(shiny)
library(shinydashboard)
library(leaflet)
library(scales)
library(forecast)
library(leaflet.extras)

# Load data
data_merged <- read.csv("../data/Disaster_Map.csv")
combined <- read.csv("../data/Disaster_Hist.csv")
monthly_disasters <- read.csv("../data/Disaster_Monthly.csv")

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  
  # Map for disaster count and project cost
  reactive_data <- reactive({
    map_filtered <- data_merged %>%
      filter(Year == input$year) %>%
      mutate(radius = case_when(
        input$metric == "frequency" ~ sqrt(frequency) * 1000, # adjust point size
        TRUE ~ sqrt(TotalProjectCost/1e6) * 1000 # adjust point size
        ))
    map_filtered
  })
  
  output$map <- renderLeaflet({
    map_filtered <- reactive_data()
    
    pal <- colorFactor(rainbow(length(unique(map_filtered$DisasterCategory))),
                       map_filtered$DisasterCategory)
    
    leaflet(map_filtered) %>%
      addTiles() %>%
      setView(lng = -98.583333, lat = 39.833333, zoom = 4) %>% # set map view to US
      addCircles(lng = ~longitude, lat = ~latitude, weight = 1,
                 radius = ~radius,
                 color = ~pal(DisasterCategory),
                 popup = ~paste(name, "<br>", DisasterCategory, "<br>", Year, "<br>", input$metric, ":", 
                                getMetricValue(input$metric, frequency, TotalProjectCost))) %>%
      addLegend("bottomright", pal = pal, values = ~DisasterCategory, title = "Disaster Type", opacity = 0.8)
  })
  
  getMetricValue <- function(metric, frequency, totalCost) {
    if(metric == "frequency") {
      return(frequency)
    } else {
      return(totalCost)
    }
  }
  
  # Statistical Analysis
  filtered_stats <- reactive({
    combined %>%
      filter(year(incidentBeginDate) == input$year,
             incidentType == input$disasterType)
  })
  
  output$stat_hist <- renderPlot({
    states <- filtered_stats()$state
    occurrences <- sort(table(states),decreasing = TRUE)
    
    barplot(occurrences, main = "Disaster Occurrences by State", 
            xlab = "State", ylab = "Number of Occurrences", col = "lightblue", border = "black")
  })
  
  #ARIMA
  disasters_filtered=reactive({
    filtered_stats = filter(monthly_disasters, state == input$state)
    filtered_stats = arrange(filtered_stats, incidentBeginMonth)
    filtered_stats$incidentBeginMonth = as.Date(paste0(filtered_stats$incidentBeginMonth, "-01"))
    filtered_stats
  })
  disaster_ts=reactive({
    tem=ts(disasters_filtered()$NumberOfDisasters)
    return(tem)
  })
  
  output$arima_summary = renderPrint({
    arima(disaster_ts(),c(input$AR,input$I,input$MA))
  })
  output$forecast_plot = renderPlot({
    fit=arima(disaster_ts(),c(input$AR,input$I,input$MA))
    forecast_values <- forecast(fit, h=10)
    plot(forecast_values, main="ARIMA Forecast", xlab="Time", ylab="Value")
  })
  output$acf_plot = renderPlot({
    acf(disaster_ts(),main='ACF')
  })
  output$pacf_plot = renderPlot({
    pacf(disaster_ts(),main='PACF')
  })
}
