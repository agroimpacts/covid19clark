# Download JHU Corona virus data
# source: https://github.com/CSSEGISandData/COVID-19
# code adapted from: https://github.com/RamiKrispin/coronavirus
`%>%` <- magrittr::`%>%`
f <- here::here("inst/extdata/covid19_ts.csv")
cases <- covid19clark::get_jhu_ts(write = TRUE, filepath = f)

# daily cases
# Get latest Mass DPH case reports
previous_cases <- readr::read_csv(
  system.file("extdata/covid19_daily_archive.csv", package = "covid19clark")
)
# file.copy(f, "inst/extdata/covid19_previous.csv")

# read new mass cases. This should fail silently if there aren't any
f <- here::here("inst/extdata/covid19_daily.csv")
try(daily_cases <- covid19clark::get_jhu_daily(write = TRUE, filepath = f),
    silent = TRUE)

# append to archive
f <- here::here("inst/extdata/covid19_daily_archive.csv")
if(exists("daily_cases")) {
  if(max(daily_cases$date) > max(previous_cases$date)) {
    updated_cases <- dplyr::bind_rows(previous_cases, daily_cases)
    readr::write_csv(updated_cases,
                     path = )
  }
}
