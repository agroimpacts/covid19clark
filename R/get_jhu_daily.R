#' Read in daily case data from JHU COVID-19 web-data respository
#' @param write If TRUE, writes output as csv to filepath. Defaults to FALSE
#' @param filepath Provide filename and path to write to.
#' @return Long format database of time cases, recoveries, deaths
#' @details Downloads daily data from JHU Corona virus repo (web-data branch).
#' Data source: https://github.com/CSSEGISandData/COVID-19. If write = TRUE and
#' fielpath = NULL, a covid19_webdata_daily.csv will be written to the current
#' directory.
#' @importFrom magrittr `%>%`
#' @importFrom dplyr select rename
#' @examples
#' cases <- get_jhu_webdata_daily()
#' cases <- get_jhu_webdata_daily(write = TRUE)
#' @export
get_jhu_webdata_daily <- function(write = FALSE, filepath = NULL) {
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
                                   "covid19_webdata_daily.csv"))
  }
  return(cases)
}

#' Read in daily case data from JHU COVID-19 daily reports repository
#' @param download_date Default of NULL gives today's date, otherwise specify as
#' "dd-mm-yyyy"
#' @param write If TRUE, writes output as csv to filepath. Defaults to FALSE
#' @param filepath Provide filename and path to write to.
#' @return Long format database of time cases, recoveries, deaths
#' @details Downloads daily data from JHU Corona virus repo (master branch).
#' Data source: https://github.com/CSSEGISandData/COVID-19. If write = TRUE and
#' fielpath = NULL, a covid19_daily_reports.csv will be written to the current
#' directory.
#' @importFrom magrittr `%>%`
#' @importFrom tidyr tibble
#' @importFrom dplyr select rename_all mutate bind_cols as_tibble group_by
#' ungroup summarize
#' @importFrom lubridate as_date mdy_hm
#' @examples
#' cases <- get_jhu_daily()
#' cases <- get_jhu_daily(write = TRUE)
#' @export
get_jhu_daily <- function(download_date = NULL, write = FALSE,
                          filepath = NULL) {

  # column matching vector
  varpats <- tibble::tibble(
    pat = c("fips", "admin2", "prov", "country", "key", "update", "long", "lat",
            "confirm", "death", "recover", "active"),
    replace = c("fips", "admin2", "prov", "country",  "key", "date", "x", "y",
                "cases", "deaths", "recovered", "active"),
  )

  # read in data
  if(is.null(download_date)) download_date <- format(Sys.Date(), "%m-%d-%Y")
  path <- paste0("https://github.com/CSSEGISandData/COVID-19/raw/master/",
                 "csse_covid_19_data/csse_covid_19_daily_reports/",
                 download_date, ".csv")
  cases <- readr::read_csv(path) %>% dplyr::rename_all(tolower)   # lower case

  # match and replace varying column names
  newnames <- sapply(tolower(colnames(cases)), function(x) {
    present <- stringr::str_detect(string = x, varpats$pat)
    ifelse(any(present), varpats$replace[which(present)], NA)
  }) %>% unname
  colnames(cases) <- newnames

  # for earlier dataset, if columns are missing, add them for easy row binding
  outnames <- !varpats$replace %in% colnames(cases)
  if(any(outnames)) {
    missing_col_names <- varpats$replace[which(outnames)]
    newcols <- matrix(NA, ncol = length(which(outnames)), nrow=nrow(cases)) %>%
      data.frame() %>% as_tibble() %>% rename_all(vars(missing_col_names))
    cases <- bind_cols(cases, newcols)
  }
  cases <- cases %>% select(!!varpats$replace) %>% select(-active)

  # fix bad dates
  if(is.character(cases$date)) {
    cases <- cases %>% mutate(date = as_date(mdy_hm(date)))
  } else {
    cases <- cases %>% mutate(date = as_date(date))
  }

  # write
  if(write == TRUE) {
    fnm <- "covid19_daily_reports.csv"
    readr::write_csv(cases, path = ifelse(!is.null(filepath), filepath, fnm))
  }
  return(cases)
}


