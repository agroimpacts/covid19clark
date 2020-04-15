data("us_cases_daily")
data("us_counties")
data("us_states")

library(shiny)
library(leaflet)
library(dplyr)

cases<- us_cases_daily$county
server <- function(input, output, session) {
pal <- colorNumeric(
  palette = c('gold', 'orange', 'dark orange', 'orange red', 'red', 'dark red'),
  domain = cases)}

output$mymap <- renderLeaflet({
  leaflet(cases) %>%
    setView(lng = -99, lat = 45, zoom = 2)  %>%

    addTiles()
    addCircles(data = cases)
})


