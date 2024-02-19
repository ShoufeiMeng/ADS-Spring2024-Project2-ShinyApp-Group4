#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
###############################Install Related Packages #######################
if (!require("DT")) install.packages('DT')
if (!require("dtplyr")) install.packages('dtplyr')
if (!require("lubridate")) install.packages('lubridate')
if (!require("ggmap")) install.packages('ggmap')
if (!require("tidyverse")) install.packages('tidyverse')
if (!require("choroplethrZip")) {
  # install.packages("devtools")
  library(devtools)
  install_github('arilamstein/choroplethrZip@v1.5.0')}
if (!require("shiny")) install.packages("shiny")
if (!require("shinydashboard")) install.packages("shinydashboard")
if (!require("leaflet")) install.packages("leaflet")
if (!require("scales")) install.packages("scales")
if (!require("forecast")) install.packages("forecast")
if (!require("leaflet.extras")) install.packages("leaflet.extras")

library(dtplyr)
library(dplyr)
library(DT)
library(lubridate)
library(tidyverse)
library(shiny)
library(shinydashboard)
library(leaflet)
library(scales)
library(forecast)
library(leaflet.extras)

#Data Cleaning and Processing

# Load data
v1 <- read.csv("~/ADS-Spring2024-Project2-ShinyApp-Group4/data/FemaWebDisasterDeclarations.csv")
v2 <- read.csv("~/ADS-Spring2024-Project2-ShinyApp-Group4/data/DisasterDeclarationsSummaries.csv")
v3 <- read.csv("~/ADS-Spring2024-Project2-ShinyApp-Group4/data/PublicAssistanceApplicantsProgramDeliveries.csv")

# Handle Missing Values
na_count <- v1 %>%
  summarise_all(~sum(is.na(.)))

v1_sel <- v1 %>%
  select(disasterName, stateCode, declarationType, disasterNumber)
v2_sel <- v2 %>% 
  select(state, disasterNumber, incidentType,incidentBeginDate,incidentEndDate, designatedArea)
v3_sel <- v3 %>% 
  select(currentProjectCost, disasterNumber)

combined <- inner_join(v1_sel, v2_sel, by = "disasterNumber")
combined_df<- inner_join(combined, v3_sel, by = "disasterNumber")

# Combine Disaster Type
combined1 <- combined_df %>%
  mutate(DisasterCategory = case_when(
    incidentType %in% c("Dam/Levee Break", "Earthquake","Fire","Flood", "Freezing", "Tsunami", "Volcanic Eruption", "Mud/Landslide", "Drought") ~ "Natural Disasters",
    incidentType %in% c("Chemical", "Toxic Substances", "Human Cause", "Terrorist") ~ "Human-caused Disasters",
    incidentType %in% c("Coastal Storm","Hurricane","Tropical Storm","Severe Storm", "Snowstorm", "Winter Storm", "Severe Ice Storm", "Tornado", "Typhoon") ~ "Severe Weather",
    incidentType %in% c("Biological") ~ "Biological",
    TRUE ~ "Others"  # Default category for anything else
  ))

# Years for Map
combined2 <- combined1 %>%
  mutate(
    incidentBeginMonth = format(ymd_hms(incidentBeginDate), "%Y-%m")
  )

combined2$Year <- sub("-.*", "", combined2$incidentBeginMonth)

#To sort the data frame in ascending order of year
combined2 <- combined2 %>%
  mutate(Year = as.numeric(Year)) %>%
  arrange(Year)

# Calculate the occurrence counts for each state and disaster type in each year
disaster_counts <- combined2 %>%
  group_by(state = stateCode, DisasterCategory,Year) %>%
  summarise(frequency = n()) 
head(disaster_counts)

# Calculate the cost of disaster for each state and disaster type in each year
head(combined2)
disaster_costs <- combined2 %>%
  group_by(stateCode, DisasterCategory,Year) %>%
  summarise(TotalProjectCost = sum(currentProjectCost, na.rm = TRUE), .groups = "drop")
head(disaster_costs,5)

# Time Series
combined3 <- combined %>%
  mutate(DisasterCategory = case_when(
    incidentType %in% c("Dam/Levee Break", "Earthquake","Fire","Flood", "Freezing", "Tsunami", "Volcanic Eruption", "Mud/Landslide", "Drought") ~ "Natural Disasters",
    incidentType %in% c("Chemical", "Toxic Substances", "Human Cause", "Terrorist") ~ "Human-caused Disasters",
    incidentType %in% c("Coastal Storm","Hurricane","Tropical Storm","Severe Storm", "Snowstorm", "Winter Storm", "Severe Ice Storm", "Tornado", "Typhoon") ~ "Severe Weather",
    incidentType %in% c("Biological") ~ "Biological",
    TRUE ~ "Others"  # Default category for anything else
  ))

combined4 <- combined3 %>%
  mutate(
    incidentBeginMonth = format(ymd_hms(incidentBeginDate), "%Y-%m")
  )

monthly_disasters <- combined4 %>%
  group_by(incidentBeginMonth) %>%
  summarise(NumberOfDisasters = n())

monthly_disasters$incidentBeginMonth <- as.Date(paste0(monthly_disasters$incidentBeginMonth, "-01"))
start_year <- as.numeric(format(min(monthly_disasters$incidentBeginMonth), "%Y"))
start_month <- as.numeric(format(min(monthly_disasters$incidentBeginMonth), "%m"))

# Calculate the occurrence counts for each state and disaster type
disaster_counts_ts <- combined4 %>%
  group_by(state = stateCode, DisasterCategory) %>%
  summarise(frequency = n())

monthly_disasters <- combined4 %>%
  group_by(incidentBeginMonth, state) %>%
  summarise(NumberOfDisasters = n())

# combine state location and disaster info for map
state_location <- read.csv("~/ADS-Spring2024-Project2-ShinyApp-Group4/data/UsStateLocation.csv")
combined_disaster <- inner_join(disaster_counts, disaster_costs, by = c("state"="stateCode", "Year", "DisasterCategory"))
data_merged <- merge(combined_disaster, state_location, by = "state")


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
    start_year = as.numeric(format(min(disasters_filtered()$incidentBeginMonth), "%Y"))
    start_month = as.numeric(format(min(disasters_filtered()$incidentBeginMonth), "%m"))
    tem=ts(disasters_filtered()$NumberOfDisasters, start = c(start_year, start_month), frequency = 12)
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