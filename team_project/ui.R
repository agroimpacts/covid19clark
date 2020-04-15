library(shiny)
library(leaflet)
library(dplyr)

ui <- fluidPage(
  mainPanel(

    leafletOutput(outputId = "mymap"),

    )
  )
