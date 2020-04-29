library(shiny)
library(leaflet)
library(RColorBrewer)
# install.packages("COVID19")
library(COVID19)
#install.packages("covid19clark")
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


us_cases_county_specic <- us_cases_county %>% select(county.x, state1) %>% distinct()


us_cases_state_specic <- us_cases_state %>% select(state1) %>% distinct()




ui <- bootstrapPage(
  span(textOutput("message"), style="color:red"),

  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  titlePanel("COVID19 Daily Cases/Deaths Data"),
  sidebarLayout(
  sidebarPanel(selectInput("extent", "Geographic Extent", list("County", "State")),
               selectInput("colors", "Color Scheme", rownames(subset(brewer.pal.info, category %in%
                                              c("seq", "div")))
                )
               ,
                selectInput("caseordeath", "Cases/Deaths", list("Cases", "Deaths"))
                ,
                dateInput(inputId = "dateinput", label = "Input Date",
                          value = max(us_cases_county$date),
                          min = min(us_cases_county$date),
                          max = max(us_cases_county$date))
               ,
                selectInput("state", "States for Charts", us_cases_state_specic)
               ,
                checkboxInput("legend", "Show legend", TRUE)


  ),
  mainPanel(
    tabsetPanel(
      tabPanel("Map",
               leafletOutput('maps', width = "105%", height = 800)
      ),
      tabPanel("Graphs", plotOutput("plot1", click = "plot_click"),
               verbatimTextOutput("info")),
      tabPanel("Table", DT::dataTableOutput("table"))
    )),
  )

)



server <- function(input, output, session) {


  ## Interactive Map ###########################################

  # Create the map
  output$maps <- renderLeaflet({
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
        scalar <- 6000
        opacity <- 1
      } else {
        us_value_vector <- us_deaths_county_max
        extentBy <-  us_deaths_county_max
        values_COVID <- us_deaths_county_max$deaths
        scalar <- 6000
        opacity <- 1
      }
    }else if (input$extent == "State") {
      if (input$caseordeath == "cases") {
        us_value_vector <- us_cases_state_max
        extentBy <-  us_cases_state_max
        values_COVID <- us_cases_state_max$cases
        scalar <- 6000
        opacity <- 1
      } else {
        us_value_vector <- us_deaths_state_max
        extentBy <-  us_deaths_state_max
        values_COVID <- us_deaths_state_max$deaths
        scalar <- 6000
        opacity <- 1
      }
    }


    colorData <- input$colors
    pal <- colorBin(pal = input$colors, domain = values_COVID, bins = 8)


    #binpal <- colorBin("Blues", us_cases_daily$state)
    leafletProxy("maps", data = us_value_vector) %>%
      clearShapes() %>%
      addCircles(~extentBy$x, ~extentBy$y,
                 stroke=FALSE, fillOpacity=opacity,
                 weight = 1, radius = log10(values_COVID) * scalar,
                 popup = ~as.character(paste0(extentBy$county.x, sep = ", ", extentBy$state1)),
                 label = ~as.character(paste0("Amount of", sep = " ", input$caseordeath, sep = ": ", values_COVID)),
                 color = ~pal(values_COVID)) %>%
      addLegend("topleft", pal=pal, values= ~values_COVID, title=colorBy,
                layerId="colorLegend", bins = 50, labFormat = labelFormat())

  })
 output$table <- DT::renderDataTable({
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
       scalar <- 5000
       opacity <- 1
     } else {
       us_value_vector <- us_deaths_county_max
       extentBy <-  us_deaths_county_max
       values_COVID <- us_deaths_county_max$deaths
       scalar <- 5000
       opacity <- 1
     }
   }else if (input$extent == "State") {
     if (input$caseordeath == "cases") {
       us_value_vector <- us_cases_state_max
       extentBy <-  us_cases_state_max
       values_COVID <- us_cases_state_max$cases
       scalar <- 5000
       opacity <- 1
     } else {
       us_value_vector <- us_deaths_state_max
       extentBy <-  us_deaths_state_max
       values_COVID <- us_deaths_state_max$deaths
       scalar <- 5000
       opacity <- 1
     }
   }

   DT::datatable(us_value_vector, options = list(orderClasses = TRUE))
 })

 output$plot1 <- renderPlot({
   us_cases_county_max <- us_cases_county %>% filter(date == input$dateinput)

   us_cases_county_specic <- us_cases_county %>% select(county.x, state1) %>% distinct()

   us_cases_state_max <- us_cases_state %>% filter(date == input$dateinput)

   us_cases_state_specic <- us_cases_state %>% select(state1) %>% distinct()

   us_deaths_county_max <- us_deaths_county %>% filter(date == input$dateinput)

   us_deaths_state_max <- us_deaths_state %>% filter(date == input$dateinput)

   if (input$extent == "County") {

     if (input$caseordeath == "Cases") {
       us_value_vector <- us_cases_county_max
       extentBy <-  us_cases_county_max
       values_COVID <- us_cases_county_max$cases
       scalar <- 5000
       opacity <- 1
     } else {
       us_value_vector <- us_deaths_county_max
       extentBy <-  us_deaths_county_max
       values_COVID <- us_deaths_county_max$deaths
       scalar <- 5000
       opacity <- 1
     }
   }else if (input$extent == "State") {
     if (input$caseordeath == "cases") {
       us_value_vector <- us_cases_state_max
       extentBy <-  us_cases_state_max
       values_COVID <- us_cases_state_max$cases
       scalar <- 5000
       opacity <- 1
     } else {
       us_value_vector <- us_deaths_state_max
       extentBy <-  us_deaths_state_max
       values_COVID <- us_deaths_state_max$deaths
       scalar <- 5000
       opacity <- 1
     }
   }
   state_select <- us_cases_daily$state %>% filter(state1 == input$state)
   ggplot() + geom_line(aes(state_select$date, log10(state_select$cases))) + geom_line(aes(state_select$date,log10(state_select$deaths)))
 })

 output$info <- renderText({
   paste0("x=", input$plot_click$x, "\ny=", input$plot_click$y)
 })
}

shinyApp(ui, server)


