#' Read in cases data from CT DPH daily COVID-19 updates
#' @param query_date User provided date or defaults to NULL (for today)
#' @param URL Path to covid-19 page of CT DPH
#' @return Table of county infections
#' @details CT provides an easier interface to scrape than MA, so the function
#' is much simpler
#' @importFrom magrittr `%>%`
#' @importFrom dplyr mutate slice filter rename_all vars select
#' @importFrom rvest html_table
#' @export
get_ct_cases <- function(query_date = NULL,
                         URL = "https://portal.ct.gov/Coronavirus") {
  webpage <- xml2::read_html(URL)
  cases <- webpage %>% html_table() %>% .[[1]] %>% as_tibble
  dtstring <- gsub("\\|.*", "", strsplit(cases$X1[1], "\\: ")[[1]][2])
  report_date <- lubridate::parse_date_time(dtstring, orders = "mdy") %>%
    lubridate::as_date()

  cases_today <- cases %>% slice(3:nrow(.)) %>%
    rename_all(vars(c("county", "cases"))) %>%
    mutate(county = gsub(" County", "", county),
           county = ifelse(county == "Total", NA, county),
           county = tolower(county)) %>%
    mutate(date = report_date, state = "connecticut") %>%
    select(state, county, date, cases)
  return(cases_today)
}
