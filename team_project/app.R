library(shiny)
library(leaflet)
library(RColorBrewer)
library(COVID19)
library(covid19clark)
library(scales)
library(lattice)
library(dplyr)
library(rgdal)
data("us_cases_daily")

ui <- bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("map", width = "100%", height = "100%"),
  absolutePanel(top = 10, right = 10,
                # sliderInput("range", "Magnitudes", min(quakes$mag), max(quakes$mag),
                #             value = range(quakes$mag), step = 0.1
                # ),
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
        } else {
          values_COVID <- extentBy$deaths
        }
      } else {
        extentBy <- us_cases_daily$state
        if (input$caseordeath == "Cases") {
          values_COVID <- extentBy$cases
        } else {
          values_COVID <- extentBy$deaths
        }
      }


      colorData <- input$colors
      pal <- colorFactor(input$colors, extentBy$cases)

      #binpal <- colorBin("Blues", us_cases_daily$state)
      leafletProxy("map", data = us_cases_daily) %>%
        clearShapes() %>%
        addCircles(~extentBy$x, ~extentBy$y,
                   stroke=FALSE, fillOpacity=0.5,
                   weight = 1, radius = ~sqrt(values_COVID)*500,
                   popup = ~as.character(paste0(extentBy$county.x, sep = ", ", extentBy$state2)),
                   label = ~as.character(paste0("Amount of", sep = " ", input$caseordeath, sep = ": ", values_COVID)),
                   color = ~pal(values_COVID)) %>%
        addLegend("bottomleft", pal=pal, values=colorData, title=colorBy,
                  layerId="colorLegend")
    })

   }

shinyApp(ui, server)

