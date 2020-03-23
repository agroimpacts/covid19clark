#' Read in daily case data from JHU COVID-19 web-data respository
#' @param write If TRUE, writes output as csv to filepath. Defaults to FALSE
#' @param filepath Provide filename and path to write to.
#' @return Long format database of time cases, recoveries, deaths
#' @details Downloads daily data from JHU Corona virus repo (web-data branch).
#' Data source: https://github.com/CSSEGISandData/COVID-19. If write = TRUE and
#' fielpath = NULL, a covid19_daily_cases.csv will be written to the current
#' directory.
#' @importFrom magrittr `%>%`
#' @importFrom dplyr select rename
#' @examples
#' cases <- get_jhu_daily()
#' cases <- get_jhu_daily(write = TRUE)
#' @export
get_jhu_daily <- function(write = FALSE, filepath = NULL) {
  path <- paste0("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/",
                 "web-data/data/cases.csv")
  cases <- readr::read_csv(path) %>%
    rename(x = Long_, y = Lat, date = Last_Update, fips = FIPS, admin = Admin2,
           prov = Province_State, ctry = Country_Region, cases = Confirmed,
           deaths = Deaths, recovered = Recovered) %>%
    dplyr::select(fips, ctry, admin, prov, x, y, date, !!colnames(.))

  # write
  if(write == TRUE) {
    readr::write_csv(cases,
                     path = ifelse(!is.null(filepath), filepath,
                                   "covid19_daily_cases.csv"))
  }
  return(cases)
}

