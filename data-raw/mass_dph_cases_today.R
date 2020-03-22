# Get latest Mass DPH case reports
`%>%` <- magrittr::`%>%`
previous_cases <- readr::read_csv(
  system.file("extdata/mass_dph_cases_previous.csv", package = "covid19clark")
)

# read new mass cases. This should fail silently if there aren't any
try(new_mass_cases <- covid19clark::get_ma_cases(), silent = TRUE)

if(exists("new_mass_cases")) {
  if(max(new_mass_cases$date) > max(previous_cases$date)) {
    updated_cases <- dplyr::bind_rows(previous_cases, new_mass_cases)
  } else {
    updated_cases <- previous_cases
  }
  # write out new files
  f <- here::here("inst/extdata/mass_dph_cases_current.csv")
  readr::write_csv(updated_cases, path = f)
  # file.copy(here::here("inst/extdata/mass_dph_cases_previous.csv"),
  #           here::here("inst/extdata/mass_dph_cases_initial.csv"))

  # copy old current to new
  file.copy(here::here("inst/extdata/mass_dph_cases_current.csv"),
            here::here("inst/extdata/mass_dph_cases_previous.csv"),
            overwrite = TRUE)
}

