# Prepare US census data for package
library(tidycensus)
library(dplyr)
library(sf)

county <- get_estimates(geography = "county", product = "population",
                        geometry = TRUE) %>% filter(variable == "POP")
# county %>% filter(grepl("Massachusetts", NAME)) %>% select(NAME) %>% plot()
us_counties <- rmapshaper::ms_simplify(county, keep = 0.1, weight = 0.7)

us_counties <- us_counties %>%
  mutate(county = tolower(gsub(",.*", "", NAME))) %>%
  mutate(county = gsub(" county", "", county)) %>%
  mutate(state = tolower(gsub(".*, ", "", NAME))) %>%
  select(state, county, value) %>% rename(pop = value)
us_counties <- us_counties %>% st_centroid() %>% st_coordinates() %>%
  as_tibble() %>% bind_cols(us_counties, .) %>%
  select(state, county, pop, X, Y) %>% rename(x = X, y = Y) %>%
  st_transform(crs = 4326)
us_states <- us_counties %>% group_by(state) %>% summarize(pop = sum(pop))
us_states <- us_states %>% st_centroid() %>% st_coordinates() %>%
  as_tibble() %>% bind_cols(us_states, .) %>%
  select(state, pop, X, Y) %>% rename(x = X, y = Y)
save(us_counties, file = here::here("data/us_counties.rda"))
save(us_states, file = here::here("data/us_states.rda"))

# state <- get_estimates(geography = "state", product = "population")
# state %>% dplyr::summarise(sum(value, na.rm = TRUE))
# state_s %>% dplyr::summarise(sum(pop, na.rm = TRUE))
# county_s %>% dplyr::summarise(sum(pop, na.rm = TRUE))
