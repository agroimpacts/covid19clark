# get old cases from DPH
`%>%` <- magrittr::`%>%`

dvec <- paste0("march-", sprintf("%02i", 13:17), "-2020")
dph_tabs <- lapply(dvec, function(x) {  # x <- dvec[3]
  print(x)
  # fix paths
  covid19clark::get_dph_cases(path = x, query_date = lubridate::mdy(x))
}) %>% do.call(rbind, .)

readr::write_csv(dph_tabs,
                 path = here::here("inst/extdata/mass_dph_cases_previous.csv"))
