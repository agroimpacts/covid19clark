# get old cases from DPH
library(covid19clark)
`%>%` <- magrittr::`%>%`

dvec <- paste0("march-", sprintf("%02i", 13:17), "-2020")
dph_tabs <- lapply(dvec, function(x) {  # x <- dvec[3]
  print(x)
  get_dph_cases(x)
}) %>% do.call(rbind, .)

readr::write_csv(dph_tabs,
                 path = here::here("inst/extdata/mass_dph_cases_previous.csv"))
