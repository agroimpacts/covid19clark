# Download JHU Corona virus data
# source: https://github.com/CSSEGISandData/COVID-19
# code adapted from: https://github.com/RamiKrispin/coronavirus

library(tidyverse)
jhu_path <- glue::glue("https://raw.githubusercontent.com/CSSEGISandData/",
                       "COVID-19/master/csse_covid_19_data/",
                       "csse_covid_19_time_series/",
                       "time_series_19-covid-Confirmed.csv")
cases_raw <- jhu_dat <- readr::read_csv(file = jhu_path)

# wide to long
cases_long <- cases_raw %>%
  pivot_longer(cols = 5:ncol(.), names_to = "date", values_to = "cases") %>%
  mutate(date = lubridate::as_date(lubridate::mdy(date))) %>%
  rename(admin = `Province/State`, ctry = `Country/Region`,
         y = Lat, x = Long) %>% dplyr::select(admin, ctry, x, y, date, cases)

# write to inst/extdata
readr::write_csv(cases_long,
                 path = here::here("inst/extdata/covid19_daily.csv"))

# build package and create updated files for README
devtools::install()
rmarkdown::render(input = here::here('vignettes/regional-cases.Rmd'),
                  output_file = here::here('vignettes/regional-cases.html'))
rmarkdown::render(input = here::here('README.Rmd'),
                  output_file = here::here("README.md"))

# commit changes
git2r::add(".", path = unname(unlist(git2r::status(".", untracked = FALSE))))
git2r::commit(".", message = paste("Package update on", lubridate::now()))
system("git push")
