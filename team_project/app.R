library(shiny)
library(leaflet)
library(RColorBrewer)
# install.packages("COVID19")
library(COVID19)
# install.packages("covid19clark")
library(covid19clark)
library(scales)
library(lattice)
library(dplyr)
library(rgdal)
library(rsconnect)
data("us_cases_daily")

us_cases_county <- us_cases_daily$county %>%
  filter((cases > 0) & (!is.na(cases)))

us_cases_state <- us_cases_daily$state %>%
  filter((cases > 0) & (!is.na(cases)))

us_deaths_county <- us_cases_daily$county %>%
  filter((deaths > 0) & (!is.na(deaths)))

us_deaths_state <- us_cases_daily$state %>%
  filter((deaths > 0) & (!is.na(deaths)))

ui <- bootstrapPage(
  span(textOutput("message"), style="color:red"),
  tabsetPanel(
    tabPanel("Map",
             uiOutput("inputs"),
             tableOutput("table"),),
    tabPanel("Graphs", uiOutput("res")),
    tabPanel("Table", verbatimTextOutput("warnings"))
  ),
  titlePanel("COVID19 Daily Cases/Deaths Data"),
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("map", width = "100%", height = "100%"),
  absolutePanel(top = 110, right = 10,

                selectInput("extent", "Geographic Extent", list("County", "State"))
                ,
                selectInput("colors", "Color Scheme",
                            rownames(subset(brewer.pal.info, category %in%
                                              c("seq", "div")))
                ),
                selectInput("caseordeath", "Cases/Deaths", list("Cases", "Deaths"))
                ,
                dateInput(inputId = "dateinput", label = "Input Date",
                          value = max(us_cases_county$date),
                          min = min(us_cases_county$date),
                          max = max(us_cases_county$date)),
                checkboxInput("legend", "Show legend", TRUE)


  )
)



server <- function(input, output, session) {

  ## Interactive Map ###########################################

  # Create the map
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles(
        urlTemplate = "https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png",
        attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
      ) %>%
      setView(lng = -93.85, lat = 37.45, zoom = 4.5)
  })


  observe({
    colorBy <- input$color
    sizeBy <- input$size

    us_cases_county_max <- us_cases_county %>% filter(date == input$dateinput)

    us_cases_state_max <- us_cases_state %>% filter(date == input$dateinput)

    us_deaths_county_max <- us_deaths_county %>% filter(date == input$dateinput)

    us_deaths_state_max <- us_deaths_state %>% filter(date == input$dateinput)

    if (input$extent == "County") {

      if (input$caseordeath == "Cases") {
        us_value_vector <- us_cases_county_max
        extentBy <-  us_cases_county_max
        values_COVID <- us_cases_county_max$cases
        scalar <- 500
        opacity <- .5
      } else {
        us_value_vector <- us_deaths_county_max
        extentBy <-  us_deaths_county_max
        values_COVID <- us_deaths_county_max$deaths
        scalar <- 500
        opacity <- .5
      }
    }else if (input$extent == "State") {
      if (input$caseordeath == "cases") {
        us_value_vector <- us_cases_state_max
        extentBy <-  us_cases_state_max
        values_COVID <- us_cases_state_max$cases
        scalar <- 500
        opacity <- .5
      } else {
        us_value_vector <- us_deaths_state_max
        extentBy <-  us_deaths_state_max
        values_COVID <- us_deaths_state_max$deaths
        scalar <- 500
        opacity <- .5
      }
    }


    colorData <- input$colors
    pal <- colorQuantile(pal = input$colors, domain = values_COVID, n = 8)


    #binpal <- colorBin("Blues", us_cases_daily$state)
    leafletProxy("map", data = us_value_vector) %>%
      clearShapes() %>%
      addCircles(~extentBy$x, ~extentBy$y,
                 stroke=FALSE, fillOpacity=opacity,
                 weight = 1, radius = ~sqrt(values_COVID)*scalar,
                 popup = ~as.character(paste0(extentBy$county.x, sep = ", ", extentBy$state1)),
                 label = ~as.character(paste0("Amount of", sep = " ", input$caseordeath, sep = ": ", values_COVID)),
                 color = ~pal(values_COVID)) %>%
      addLegend("topleft", pal=pal, values= ~values_COVID, title=colorBy,
                layerId="colorLegend", bins = 50, labFormat = labelFormat())
  })

}

shinyApp(ui, server)


