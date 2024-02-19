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

# Define UI for application (map, histogram, ARIMA)
ui <- fluidPage(
  titlePanel("U.S. Disaster Analysis Dashboard"),
  
  tabsetPanel(
    
    # Map showing disaster count and project cost
    tabPanel("Map",
             sidebarLayout(
               sidebarPanel(
                 selectInput("year", "Year", 
                             choices = sort(unique(data_merged$Year), decreasing = TRUE), 
                             selected = max(data_merged$Year)),
                 radioButtons("metric", "Data",
                              choices = list("Frequency" = "frequency", "Total Project Cost" = "TotalProjectCost")),
               ),
               mainPanel(
                 leafletOutput("map")
               )
             )
    ),
    
    # Statistical Analysis         
    tabPanel('Statistical Analysis',
             sidebarPanel(
               selectInput("year", "Choose a Year:", 
                           choices = sort(unique(year(combined$incidentBeginDate)), decreasing = TRUE),2023),
               selectInput("disasterType", "Choose a Disaster Type:", 
                           choices = unique(combined$incidentType))
             ),
             mainPanel(
               plotOutput("stat_hist")
             )
    ),
    
    # ARIMA
    tabPanel("ARIMA",
             sidebarPanel(
               selectInput("state", "Choose a State:",choices=unique(monthly_disasters$state)),
               sliderInput("AR", "Choose p:",0,10,0),
               sliderInput("I", "Choose d:",0,10,0),
               sliderInput("MA", "Choose q:",0,10,0)
             ),
             mainPanel(
               plotOutput("acf_plot"),
               plotOutput("pacf_plot"),
               verbatimTextOutput("arima_summary"),
               plotOutput("forecast_plot")
             )
    ),
  )
)
