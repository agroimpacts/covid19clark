# build package and create updated files for README

# get data updates
# JHU
source(here::here("data-raw/jhu_corona_virus.R"))

# # Mass MPH
# source(here::here("data-raw/mass_dph_cases_today.R"))
#
# # CT DPH
# source(here::here("data-raw/ct_dph_cases_today.R"))

# Build package
devtools::install()
rmarkdown::render(input = here::here('vignettes/ne-regional-cases.Rmd'),
                  output_file = here::here('vignettes/ne-regional-cases.html'))
rmarkdown::render(input = here::here('README.Rmd'),
                  output_file = here::here("README.md"))

# commit changes
git2r::add(".", path = unname(unlist(git2r::status(".", untracked = FALSE))))
git2r::commit(".", message = paste("Package update on", lubridate::now()))
system("git push")
