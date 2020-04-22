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

ui <- bootstrapPage(
  tabsetPanel(
    tabPanel("Inputs", uiOutput("inputs")),
    tabPanel("Test result", uiOutput("res")),
    tabPanel("Warnings", verbatimTextOutput("warnings"))
  ),
  titlePanel("COVID19 Daily Cases/Deaths Data"),
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

  warn_messages <- reactiveVal(NULL)

  # turn any warnings produced by calling a function
  # into a notification and optionally call the function
  # again to return the results (use `return = FALSE` if
  # function produces side effects)
  catchWarning <- function(f, ..., return = TRUE) {
    tryCatch(f(...), warning = function(w) {
      isolate({
        msgs <- c(warn_messages(), w$message)
        warn_messages(msgs)
      })
      if (return) f(...)
    })
  }
  output$inputs <- renderUI({
    tagList(

      catchWarning(dateRangeInput, "x4", "Mis-specified `start`", start = "null"),
    )
  })
  outputOptions(output, "inputs", suspendWhenHidden = FALSE)

  observe ({
    catchWarning(updateDateRangeInput, session, "x4", end = "x", return = FALSE)
  })

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
    us_cases_county <- us_cases_daily$county %>%
      filter((cases > 0) & (!is.na(cases)))
    us_cases_county_max <- us_cases_county %>% filter(date == max(date))

    us_cases_state <- us_cases_daily$state %>%
      filter((cases > 0) & (!is.na(cases)))
    us_cases_state_max <- us_cases_state %>% filter(date == max(date))

    us_deaths_county <- us_cases_daily$county %>%
      filter((deaths > 0) & (!is.na(deaths)))
    us_deaths_county_max <- us_deaths_county %>% filter(date == max(date))

    us_deaths_state <- us_cases_daily$state %>%
      filter((deaths > 0) & (!is.na(deaths)))
    us_deaths_state_max <- us_deaths_county %>% filter(date == max(date))

    if (input$extent == "County") {
      extentBy <-  us_cases_county
      if (input$caseordeath == "Cases") {
        values_COVID <- us_cases_county$cases
        scalar <- 500
        opacity <- .5
      } else {
        values_COVID <- us_deaths_county$deaths
        scalar <- 1000
        opacity <- .5
      }
    } else {
      extentBy <- us_cases_state
      if (input$caseordeath == "Cases") {
        values_COVID <- us_cases_state$cases
        scalar <- 500
        opacity <- .5
      } else {
        values_COVID <- us_deaths_state$deaths
        scalar <- 1000
        opacity <- .5
      }
    }



    colorData <- input$colors
    pal <- colorBin(pal = input$colors, domain = values_COVID, bins = 8)


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


