#' Read in cases data from Mass DPH daily docx files
#' @param path User provided path for specific doc, defaults to NULL
#' @param query_date User provided date or defaults to NULL (for today)
#' @param URL Path to covid-19 page of Mass DPH
#' @return Table of county infections
#' @details Provide a specific path to dph_path, otherwise if kept as default
#' NULL, function will scrape from the latest days COVID-19 cases reports
#' @importFrom magrittr `%>%`
#' @importFrom dplyr mutate slice filter rename_all vars
#' @importFrom rvest html_node html_nodes html_attr
#' @export
get_ma_cases <- function(
  path = NULL,
  query_date = NULL,
  URL = paste0("https://www.mass.gov/info-details/",
               "covid-19-cases-quarantine-and-monitoring")
) {
  if(is.null(path)) {
    # scrape

    webpage <- xml2::read_html(URL)
    path <- webpage %>% #html_node(".ma__table--responsive") %>%
      html_node("div.main-content") %>%
      html_node("div.ma__rich-text") %>%
      html_node("div.ma__rich-text") %>% html_nodes(xpath = "p/a") %>%
      html_attr("href") %>% .[(grepl("accessible", .))] %>%
      paste0("https://www.mass.gov", .)
    pat <- paste("https://www.mass.gov/doc/", "/download", "accessible",
                 "covid-19", "cases", "in", "massachusetts", "as", "of", "-",
                 sep = "|")
    query_date <- lubridate::mdy(gsub(pat, "", path))
  }
  txt <- docxtractr::read_docx(path)  # read in file
  tab <- docxtractr::docx_extract_all_tbls(txt)  # read in all tables
  # find the table that contains the word "County"
  tab <- tab[[which(sapply(tab, function(x) x[1, 1] == "County"))]]
  tab %>%
    slice(-(which(grepl("^sex", x = CATEGORY, ignore.case = TRUE)):nrow(.))) %>%
    filter(CATEGORY != "County") %>%
    rename_all(vars(c("county", "cases"))) %>%
    mutate(date = query_date) %>%
    mutate(cases = as.numeric(cases)) %>%
    mutate(state = "massachusetts", county = tolower(county)) %>%
    dplyr::select(state, county, date, cases)
}
