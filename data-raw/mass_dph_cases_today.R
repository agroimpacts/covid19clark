# Get latest Mass DPH case reports

`%>%` <- magrittr::`%>%`
today <- Sys.Date()
mph_date <- paste0(c(tolower(months(today)), substr(today, 9, 10),
                     substr(today, 1, 4)), collapse = "-")

# read new mass cases. This should fail silently if there aren't any
try(new_mass_cases <- covid19clark::get_dph_cases(mph_date), silent = TRUE)

# if there are new cases, combine with the old ones
if(exists("new_mass_cases")) {
  previous_cases <- readr::read_csv(
    system.file("extdata/mass_dph_cases_previous.csv", package = "covid19clark")
  )
  # for testing before updates
  # new_mass_cases <- previous_cases %>%
  #   dplyr::filter(date == as.Date("2020-03-17"))
  # previous_cases <- previous_cases %>%
  #   dplyr::filter(date < as.Date("2020-03-17"))
  if(!unique(new_mass_cases$date) %in% unique(previous_cases$date)) {
    updated_cases <- dplyr::bind_rows(previous_cases, new_mass_cases)
  } else {
    updated_cases <- previous_cases
  }
  # write out new files
  readr::write_csv(updated_cases,
                   path = here::here("inst/extdata/mass_dph_cases_current.csv"))
  # file.copy(here::here("inst/extdata/mass_dph_cases_previous.csv"),
  #           here::here("inst/extdata/mass_dph_cases_initial.csv"))

  # copy old current to new
  file.copy(here::here("inst/extdata/mass_dph_cases_current.csv"),
            here::here("inst/extdata/mass_dph_cases_previous.csv"),
            overwrite = TRUE)
}
