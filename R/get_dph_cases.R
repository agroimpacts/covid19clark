#' Read in cases data from Mass DPH daily docx files
#' @param filepath URL of path to daily docx of COVID cases posted to DPH site
#' @return Table of county infections
#' @importFrom magrittr `%>%`
#' @importFrom dplyr mutate slice filter rename_all vars
#' @export
get_dph_cases <- function(mph_date) {
  filepath <- paste0("https://www.mass.gov/doc/covid-19-cases-in-",
                     "massachusetts-as-of-", mph_date, "-accessible/download")
  txt <- docxtractr::read_docx(filepath)  # read in file
  tab <- docxtractr::docx_extract_all_tbls(txt)  # read in all tables
  # find the table that contains the word "County"
  tab <- tab[[which(sapply(tab, function(x) x[1, 1] == "County"))]]
  tab %>%
    slice(-(which(grepl("^sex", x = CATEGORY, ignore.case = TRUE)):nrow(.))) %>%
    filter(CATEGORY != "County") %>%
    rename_all(vars(c("county", "cases"))) %>%
    mutate(date = lubridate::mdy(mph_date)) %>%
    mutate(cases = as.numeric(cases)) %>%
    dplyr::select(date, !!colnames(.))
}
