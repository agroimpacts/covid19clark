# Download JHU Corona virus data
# source: https://github.com/CSSEGISandData/COVID-19
# code adapted from: https://github.com/RamiKrispin/coronavirus
`%>%` <- magrittr::`%>%`
library(lubridate)
library(covid19clark)

# switched off for now because of change in dataset
# f <- here::here("inst/extdata/covid19_ts.csv")
# cases <- covid19clark::get_jhu_ts(write = TRUE, filepath = f)

# daily cases
previous_cases <- readr::read_csv(
  system.file("extdata/covid19_daily_reports.csv", package = "covid19clark"),
  # prevent coercion to logical bc NA
  col_types = readr::cols(fips = readr::col_character(),
                          admin2 = readr::col_character(),
                          key = readr::col_character())
)
# previous_cases %>% dplyr::filter(date == max(date))
# previous_cases <- previous_cases %>% dplyr::filter(date != max(date))
# previous_cases <- previous_cases %>% dplyr::filter(date < Sys.Date() - 4)
# file.copy(f, "inst/extdata/covid19_previous.csv", overwrite = TRUE)
# readr::write_csv(previous_cases, path = f)

# read new mass cases. This should fail silently if there aren't any
# daily_cases <- covid19clark::get_jhu_daily(download_date = "03-28-2020",
#                                            write = FALSE)
last_date <- max(unique(previous_cases$date))
tdiff <- Sys.Date() - last_date
if(tdiff > 0) {
  tseries <- seq.Date(last_date, Sys.Date(), by = "d")[-1]
  daily_casesl <- lapply(tseries, function(x) {  # x <- tseries[5]
    qdate <- strftime(x, "%m-%d-%Y")
    try(daily_cases <- covid19clark::get_jhu_daily(qdate, write = FALSE),
        silent = TRUE)
    if(exists("daily_cases")) {
      if(max(daily_cases$date) > "2020-04-22") {
        fixdate <- x
        daily_cases <- daily_cases %>% dplyr::mutate(date = fixdate)
      }
      return(daily_cases)
    } else {
      return(NULL)
    }
  })
  # daily_casesl[[1]] <- NULL
  daily_cases_df <- do.call(rbind, daily_casesl)
  daily_cases_df <- daily_cases_df %>% dplyr::mutate(fips = as.character(fips))

  f <- here::here("inst/extdata/covid19_daily_reports.csv")
  if(!is.null(daily_cases_df)) {
    updated_cases <- dplyr::bind_rows(previous_cases, daily_cases_df)
    # updated_cases <- previous_cases
    readr::write_csv(updated_cases, path = f)

    # data(us_cases_daily, package = "covid19clark")
    # load("data/us_cases_daily.rda")

    # run cleaning for US cases
    # case_data <- updated_cases
    # us_cases_daily <- covid19clark::us_cases(previous_cases)
    # us_cases_daily <- covid19clark::us_cases(updated_cases)
    # sf::st_write(us_cases_daily$state, delete_dsn = TRUE,
    #              dsn = here::here("inst/extdata/us_state_cases_daily.geojson"))
    # # save(us_cases_daily, file = here::here("data/us_cases_daily.rda"))
    # sf::st_write(us_cases_daily$county, delete_dsn = TRUE,
    #              dsn = here::here("inst/extdata/us_county_cases_daily.geojson"))
    }
}


# # append to archive
# f <- here::here("inst/extdata/covid19_daily_reports.csv")
# if(exists("daily_cases")) {
#   if(max(daily_cases$date) > max(previous_cases$date)) {
#
#     # write to daily_reports updated
#     updated_cases <- dplyr::bind_rows(previous_cases, daily_cases)
#   } else {
#     updated_cases <- previous_cases
#   }
#
#   # updated_cases <- previous_cases
#   readr::write_csv(updated_cases, path = f)
#
#   # run cleaning for US cases
#   us_cases_daily <- covid19clark::us_cases(updated_cases)
#   save(us_cases_daily, file = here::here("data/us_cases_daily.rda"))
# }
#
