library(shiny)
library(leaflet)
library(RColorBrewer)
library(COVID19)
library(covid19clark)
library(scales)
library(lattice)
library(dplyr)
library(rgdal)
library(rsconnect)
data("us_cases_daily")

ui <- bootstrapPage(
  titlePanel("COVID19 Data"),
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("map", width = "100%", height = "100%"),
  absolutePanel(top = 70, right = 10,
                selectInput("extent", "Geographic Extent", list("County", "State"))
                ,
                selectInput("colors", "Color Scheme",
                            rownames(subset(brewer.pal.info, category %in% c("seq", "div")))
                ),
                selectInput("caseordeath", "Cases/Deaths", list("Cases", "Deaths"))
                ,
                checkboxInput("legend", "Show legend", TRUE)


  )
)




server <- function(input, output, session) {

  ## Interactive Map ###########################################

  # Create the map
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles(
        urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
        attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
      ) %>%
      setView(lng = -93.85, lat = 37.45, zoom = 4)
  })


  observe({
    colorBy <- input$color
    sizeBy <- input$size

    if (input$extent == "County") {
      extentBy <- us_cases_daily$county
      if (input$caseordeath == "Cases") {
        values_COVID <- extentBy$cases
        scalar <- 500
        opacity <- .5
      } else {
        values_COVID <- extentBy$deaths
        scalar <- 2000
        opacity <- .25
      }
    } else {
      extentBy <- us_cases_daily$state
      if (input$caseordeath == "Cases") {
        values_COVID <- extentBy$cases
        scalar <- 500
        opacity <- .5
      } else {
        values_COVID <- extentBy$deaths
        scalar <- 500
        opacity <- .25
      }
    }


    colorData <- input$colors
    pal <- colorFactor(input$colors, values_COVID)


    #binpal <- colorBin("Blues", us_cases_daily$state)
    leafletProxy("map", data = us_cases_daily) %>%
      clearShapes() %>%
      addCircles(~extentBy$x, ~extentBy$y,
                 stroke=FALSE, fillOpacity=opacity,
                 weight = 1, radius = ~sqrt(values_COVID)*scalar,
                 popup = ~as.character(paste0(extentBy$county.x, sep = ", ", extentBy$state2)),
                 label = ~as.character(paste0("Amount of", sep = " ", input$caseordeath, sep = ": ", values_COVID)),
                 color = ~pal(values_COVID)) %>%
      addLegend("topleft", pal=pal, values= ~values_COVID, title=colorBy,
                layerId="colorLegend", bins = 50, labFormat = labelFormat())
  })

}

shinyApp(ui, server)

