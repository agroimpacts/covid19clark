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
library(ggplot2)
# devtools::install_version("MASS", "7.3-51.1")
data("us_cases_daily")

us_cases_county <- us_cases_daily$county %>%
  filter((cases > 0) & (!is.na(cases))) %>% mutate(., caserate = cases / (pop / 1000))

us_cases_state <- us_cases_daily$state %>%
  filter((cases > 0) & (!is.na(cases))) %>% mutate(., caserate = cases / (pop / 1000))

us_deaths_county <- us_cases_daily$county %>%
  filter((deaths > 0) & (!is.na(deaths))) %>% mutate(., deathrate = deaths / (pop / 1000))

us_deaths_state <- us_cases_daily$state %>%
  filter((deaths > 0) & (!is.na(deaths))) %>% mutate(., deathrate = deaths / (pop / 1000))

us_cases_county_specic <- us_cases_county %>% select(county.x, state1) %>% distinct()


us_cases_state_specic <- us_cases_state %>% select(state1) %>% distinct()


ui <- bootstrapPage(
  span(textOutput("message"), style="color:red"),

  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  titlePanel("COVID19 Daily Cases/Deaths Data"),
  sidebarLayout(
  sidebarPanel(selectInput("extent", "Geographic Extent", list("State", "County")),
               selectInput("colors", "Color Scheme", rownames(subset(brewer.pal.info, category %in%
                                              c("seq", "div")))
                )
               ,
                selectInput("caseordeath", "cases/deaths",
                            list("cases", "deaths", "case rate", "death rate"))
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
               plotOutput("plot2", click = "plot_click"),
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

      if (input$caseordeath == "cases") {
        us_value_vector <- us_cases_county_max
        extentBy <-  us_cases_county_max
        values_COVID <- us_cases_county_max$cases
        scalar <- 6000
        opacity <- 1
      } else if (input$caseordeath == "case rate") {
        us_value_vector <- us_cases_county_max
        extentBy <-  us_cases_county_max
        values_COVID <- us_cases_county_max$caserate
        scalar <- 12000
        opacity <- 1
      } else if (input$caseordeath == "deaths") {
        us_value_vector <- us_deaths_county_max
        extentBy <-  us_deaths_county_max
        values_COVID <- us_deaths_county_max$deaths
        scalar <- 6000
        opacity <- 1
      } else {
        us_value_vector <- us_deaths_county_max
        extentBy <-  us_deaths_county_max
        values_COVID <- us_deaths_county_max$deathrate
        scalar <- 12000
        opacity <- 1

      }
    } else if (input$extent == "State") {
      if (input$caseordeath == "cases") {
        us_value_vector <- us_cases_state_max
        extentBy <-  us_cases_state_max
        values_COVID <- us_cases_state_max$cases
        scalar <- 6000
        opacity <- 1
      } else if (input$caseordeath == "case rate") {
        us_value_vector <- us_cases_state_max
        extentBy <-  us_cases_state_max
        values_COVID <- us_cases_state_max$caserate
        scalar <- 12000
        opacity <- 1
      } else if (input$caseordeath == "deaths") {
        us_value_vector <- us_deaths_state_max
        extentBy <-  us_deaths_state_max
        values_COVID <- us_deaths_state_max$deaths
        scalar <- 6000
        opacity <- 1
      } else {
        us_value_vector <- us_deaths_state_max
        extentBy <-  us_deaths_state_max
        values_COVID <- us_deaths_state_max$deathrate
        scalar <- 12000
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
                layerId="colorLegend", labFormat = labelFormat())

  })
 output$table <- DT::renderDataTable({
   colorBy <- input$color
   sizeBy <- input$size

   us_cases_county_max <- us_cases_county %>% filter(date == input$dateinput)

   us_cases_state_max <- us_cases_state %>% filter(date == input$dateinput)

   us_deaths_county_max <- us_deaths_county %>% filter(date == input$dateinput)

   us_deaths_state_max <- us_deaths_state %>% filter(date == input$dateinput)

   if (input$extent == "County") {

     if (input$caseordeath == "cases") {
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
   us_value_vector_state <- us_value_vector %>% filter(state1 == input$state)
   DT::datatable(us_value_vector_state, options = list(orderClasses = TRUE))
 })

 output$plot1 <- renderPlot({

   if (input$extent == "County") {
     if (input$caseordeath == "cases") {
       values_COVID_orig <- us_cases_county$cases
       values_COVID <- us_cases_county %>% filter(state1 == input$state)
       values_COVID <- values_COVID %>% select(date, cases)
       values_COVID_ <- log10(values_COVID$cases)
       values_COVID_dates <- values_COVID$date
     } else if (input$caseordeath == "case rate") {
       values_COVID_orig <- us_cases_county$caserate
       values_COVID <- us_cases_county %>% filter(state1 == input$state)
       values_COVID <- values_COVID %>% select(date, caserate)
       values_COVID_ <- values_COVID$caserate
       values_COVID_dates <- values_COVID$date
     } else if (input$caseordeath == "deaths") {
       values_COVID_orig <- us_deaths_county$deaths
       values_COVID <- us_deaths_county %>% filter(state1 == input$state)
       values_COVID <- values_COVID %>% select(date, deaths)
       values_COVID_ <- log10(values_COVID$deaths)
       values_COVID_dates <- values_COVID$date
     } else {
       values_COVID_orig <-us_deaths_county$deathrate
       values_COVID <- us_deaths_county %>% filter(state1 == input$state)
       values_COVID <- values_COVID %>% select(date, deathrate)
       values_COVID_ <- values_COVID$deathrate
       values_COVID_dates <- values_COVID$date
     }

   } else if (input$extent == "State") {
     if (input$caseordeath == "cases") {
       values_COVID_orig <- us_cases_state$cases
       values_COVID <- us_cases_state %>% filter(state1 == input$state)
       values_COVID <- values_COVID %>% select(date, cases)
       values_COVID_ <- log10(values_COVID$cases)
       values_COVID_dates <- values_COVID$date
     } else if (input$caseordeath == "case rate") {
       values_COVID_orig <- us_cases_state$caserate
       values_COVID <- us_cases_state %>% filter(state1 == input$state)
       values_COVID <- values_COVID %>% select(date, caserate)
       values_COVID_ <- values_COVID$caserate
       values_COVID_dates <- values_COVID$date
     } else if (input$caseordeath == "deaths") {
       values_COVID_orig <- us_deaths_state$deaths
       values_COVID <- us_deaths_state %>% filter(state1 == input$state)
       values_COVID <- values_COVID %>% select(date, deaths)
       values_COVID_ <- log10(values_COVID$deaths)
       values_COVID_dates <- values_COVID$date
     } else {
       values_COVID_orig <- us_deaths_state$deathrate
       values_COVID <- us_deaths_state %>% filter(state1 == input$state)
       values_COVID <- values_COVID %>% select(date, deathrate)
       values_COVID_ <- values_COVID$deathrate
       values_COVID_dates <- values_COVID$date
     }
   }
   ggplot() + geom_line(aes(values_COVID_dates, values_COVID_)) +
     ylim(0, max(log10(values_COVID_orig))) + xlab("Recorded Dates") +
     ylab(paste0(input$caseordeath))


   })
 output$plot2 <- renderPlot({
   us_cases_county_max <- us_cases_county %>% filter(date == input$dateinput)

   us_cases_state_max <- us_cases_state %>% filter(date == input$dateinput)

   us_deaths_county_max <- us_deaths_county %>% filter(date == input$dateinput)

   us_deaths_state_max <- us_deaths_state %>% filter(date == input$dateinput)

   if (input$extent == "County") {

     if (input$caseordeath == "cases") {
       us_value_vector <- us_cases_county_max
       extentBy <-  us_cases_county_max
       values_COVID <- us_cases_county_max$cases
       scalar <- 6000
       opacity <- 1
     } else if (input$caseordeath == "case rate") {
       us_value_vector <- us_cases_county_max
       extentBy <-  us_cases_county_max
       values_COVID <- us_cases_county_max$caserate
       scalar <- 12000
       opacity <- 1
     } else if (input$caseordeath == "deaths") {
       us_value_vector <- us_deaths_county_max
       extentBy <-  us_deaths_county_max
       values_COVID <- us_deaths_county_max$deaths
       scalar <- 6000
       opacity <- 1
     } else {
       us_value_vector <- us_deaths_county_max
       extentBy <-  us_deaths_county_max
       values_COVID <- us_deaths_county_max$deathrate
       scalar <- 12000
       opacity <- 1

     }
   } else if (input$extent == "State") {
     if (input$caseordeath == "cases") {
       us_value_vector <- us_cases_state_max
       extentBy <-  us_cases_state_max
       values_COVID <- us_cases_state_max$cases
       scalar <- 6000
       opacity <- 1
     } else if (input$caseordeath == "case rate") {
       us_value_vector <- us_cases_state_max
       extentBy <-  us_cases_state_max
       values_COVID <- us_cases_state_max$caserate
       scalar <- 12000
       opacity <- 1
     } else if (input$caseordeath == "deaths") {
       us_value_vector <- us_deaths_state_max
       extentBy <-  us_deaths_state_max
       values_COVID <- us_deaths_state_max$deaths
       scalar <- 6000
       opacity <- 1
     } else {
       us_value_vector <- us_deaths_state_max
       extentBy <-  us_deaths_state_max
       values_COVID <- us_deaths_state_max$deathrate
       scalar <- 12000
       opacity <- 1

     }
   }
   barplot(height = values_COVID, names.arg = us_value_vector$state1,
           xlab = "US States", ylab = input$caseordeath)

 })


 output$info <- renderText({
   paste0("x=", input$plot_click$x, "\ny=", input$plot_click$y)
 })
}

shinyApp(ui, server)


