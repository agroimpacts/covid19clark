# set up counties and US states
library(dplyr)
library(sf)

# county maps
counties <- st_as_sf(maps::map("county", plot = FALSE, fill = TRUE)) %>%
  lwgeom::st_make_valid() %>%
  mutate(state = gsub(",.*", "", ID)) %>%
  mutate(county = gsub(".*,", "", ID)) %>%
  dplyr::select(state, county)

# county centroids
county_centroids <- st_centroid(counties) %>%
  mutate(x = st_coordinates(.)[, 1], y = st_coordinates(.)[, 2]) %>%
  as_tibble %>% dplyr::select(state, county, x, y) %>% as_tibble()
us_counties <- left_join(counties, county_centroids) %>%
  dplyr::select(state, county, x, y)

# state maps
states <- counties %>% group_by(state) %>% dplyr::count() %>% ungroup() %>%
  dplyr::select(state)
state_centroids <- st_centroid(states) %>%
  mutate(x = st_coordinates(.)[, 1], y = st_coordinates(.)[, 2]) %>%
  as_tibble() %>% dplyr::select(state, x, y)
us_states <- left_join(states, state_centroids) %>% dplyr::select(state, x, y)

st_write(us_counties, dsn = here::here("inst/extdata/us_counties.geojson"))
st_write(us_states, dsn = here::here("inst/extdata/us_states.geojson"))
# save(counties, file = here::here("data/counties.rda"))
# save(states, file = here::here("data/states.rda"))
