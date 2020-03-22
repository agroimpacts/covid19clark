# get old cases from DPH
`%>%` <- magrittr::`%>%`

dvec <- paste0("march-", sprintf("%02i", 13:17), "-2020")
dph_tabs <- lapply(dvec, function(x) {  # x <- dvec[3]
  print(x)
  filepath <- paste0("https://www.mass.gov/doc/covid-19-cases-in-",
                     "massachusetts-as-of-", x, "-accessible/download")
  # fix paths
  covid19clark::get_ma_cases(path = filepath, query_date = lubridate::mdy(x))
}) %>% do.call(rbind, .)

readr::write_csv(dph_tabs,
                 path = here::here("inst/extdata/mass_dph_cases_previous.csv"))
