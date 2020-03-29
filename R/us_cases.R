#' Tidy JHU data for US
#' @param case_data Tibble of global cases
#' @return Tidy US datasets combining state and county level corona virus
#' @details Cleans downloaded US cases somewhat clumsily
#' @importFrom magrittr `%>%`
#' @importFrom dplyr select rename mutate filter bind_rows left_join arrange
#' @keywords internal
us_cases_clean <- function(case_data) {

  # read in and filter to US
  dat <- case_data %>% filter(country == "US")   # cho down to US
  pat <- "Unassigned Location|Grand Princess|Diamond Princess"

  # first clean
  dat <- dat %>% select(-fips, -country) %>%
    mutate(county = ifelse(grepl(",", prov), gsub(",.*", "", prov), NA)) %>%
    mutate(state = ifelse(grepl(",", prov), gsub(".*, ", "", prov), prov)) %>%
    mutate(county = gsub(" County", "", county)) %>%
    mutate(state = tolower(gsub(" \\(From Diamond Princess\\)", "", state))) %>%
    mutate(state = ifelse(state == "d.c.", "dc", state)) %>%
    filter(!grepl(pat, state, ignore.case = TRUE)) %>%
    mutate(county = ifelse(is.na(county), admin2, county)) %>%
    dplyr::select(admin2, county, prov, state, key, x, y, date, cases, deaths)

  # vector of state names for matching
  state_names <- tibble(state1 = state.name, state2 = state.abb) %>%
    mutate(state1 = tolower(state1)) %>%
    bind_rows(., tibble(state1 = "district of columbia", state2 = "DC"))

  # fix mismatching states, etc (not thoroughly checked yet)
  dat1 <- dat %>% filter(nchar(state) < 4) %>%
    rename(state2 = state) %>%
    left_join(., state_names %>% mutate(state2 = tolower(state2))) %>%
    select(state1, state2, admin2, prov, county, key, x, y, date, cases, deaths)
  dat2 <- dat %>% filter(nchar(state) > 3) %>%
    rename(state1 = state) %>%
    left_join(., state_names) %>%
    mutate(state2 = tolower(state2)) %>%
    select(state1, state2, admin2, prov, county, key, x, y, date, cases, deaths)

  # recombine
  cases_all <- bind_rows(dat1, dat2) %>% arrange(date, state1, county) %>%
    mutate(county = tolower(county))
  return(cases_all)
}

#' Tidy JHU data for US
#' @param case_data Tibble of global cases
#' @return Tidy US datasets for state and county level corona virus
#' @details Cleans downloaded US cases somewhat clumsily
#' @importFrom magrittr `%>%`
#' @importFrom dplyr select rename mutate filter bind_rows left_join arrange
#' @export
us_cases <- function(case_data) {

  # run cleaner
  # clean_cases <- covid19clark:::us_cases_clean(updated_cases)
  clean_cases <- us_cases_clean(case_data)

  # state cases
  state_cases <- clean_cases %>%
    group_by(state1, date) %>%
    summarize(cases = sum(cases), deaths = sum(deaths), state2 = unique(state2),
              x = mean(x, na.rm = TRUE), y = mean(y, na.rm = TRUE)) %>%
    ungroup() %>%
    dplyr::select(state1, state2, date, cases, deaths)
  state_cases <- state_cases %>%
    # as_tibble() %>% select(state, x, y) %>%
    left_join(us_states, ., by = c("state" = "state1")) %>%
    rename(state1 = state) %>%
    dplyr::select(state1, state2, x, y, date, cases, deaths, pop) %>%
    arrange(state1, date)

  # county cases
  county_cases <- clean_cases %>%
    filter(!grepl("unknown|unassigned", county, ignore.case = TRUE)) %>%
    filter(!is.na(county)) %>% filter(!(x == 0 & y == 0) | !is.na(x)) %>%
    group_by(state1, county, date) %>%
    mutate(cases = cumsum(cases), deaths = sum(deaths)) %>%
    ungroup() %>% sf::st_as_sf(coords = c("x", "y"), crs = 4326) %>%
    sf::st_join(us_counties, ., ) %>%
    # left_join(us_counties, ., by = c("state" = "state1")) %>%
    dplyr::select(state1, state2, county.x, county.y, x, y, date,
                  cases, deaths, pop) %>%
    arrange(state1, date)

  return(list("state" = state_cases, "county" = county_cases))
}


