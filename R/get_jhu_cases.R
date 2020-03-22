#' Read in cases data from JHU COVID-19 case respository
#' @param write If TRUE, writes output as csv to filepath. Defaults to FALSE
#' @param filepath Provide filename and path to write to.
#' @return Long format database of time cases, recoveries, deaths
#' @details Downloads time series of JHU Corona virus data, so no arguments.
#' Data source: https://github.com/CSSEGISandData/COVID-19. Code adapted
#' from: https://github.com/RamiKrispin/coronavirus. If write = TRUE and
#' fielpath = NULL, a covid19.csv will be written to the current directory
#' @importFrom magrittr `%>%`
#' @importFrom dplyr mutate select rename
#' @importFrom tidyr pivot_longer
#' @importFrom rvest html_table
#' @examples
#' cases <- get_jhu_data()
#' cases <- get_jhu_data(write = TRUE)
#' @export
get_jhu_data <- function(write = FALSE, filepath = NULL) {
  case_types <- c("Confirmed", "Deaths", "Recovered")
  path <- paste0("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/",
                 "master/csse_covid_19_data/csse_covid_19_time_series/",
                 "time_series_19-covid-", case_types, ".csv")

  cases <- lapply(1:3, function(x) {  # x <- path[2]
    dat <- readr::read_csv(file = path[x])  # read in
    dat_long <- dat %>%  # wide to long
      pivot_longer(cols = 5:ncol(.), names_to = "date",
                   values_to = case_types[x]) %>%
      mutate(date = lubridate::as_date(lubridate::mdy(date))) %>%
      rename(admin = `Province/State`, country = `Country/Region`,
             y = Lat, x = Long) %>%
      select(admin, country, x, y, date, !!case_types[x])
  }) %>% purrr::reduce(left_join) %>%
    rename(cases = Confirmed, deaths = Deaths, recovered = Recovered) %>%
    arrange(country, date)

  # write out
  if(write == TRUE) {
    readr::write_csv(cases,
                     path = ifelse(!is.null(filepath), filepath, "covid19.csv"))
  }
  return(cases)
}


