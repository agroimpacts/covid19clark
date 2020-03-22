#' Define focal_point
#' @param city Name of city appearing in maps::world.cities database
#' @param county Name of country of city
#' @param x Longitude of point of interest, provided as alternate to city name
#' @param y Latitude of point of interest, provided as alternate to city name
#' @return An sf object
#' @details Prompt for x and y coordinate if city name not found
#' @importFrom magrittr `%>%`
#' @importFrom dplyr mutate slice filter rename_all vars select
#' @examples
#' focal_point(city = "Worcester", country = "USA")
#' focal_point(city = "Worcester", country = "UK")
#' focal_point(city = "Worcester", country = "South Africa")
#' focal_point(x = 15, y = -19.1)
#' @export
focal_point <- function(city = NULL, country = NULL, x = NULL,
                        y = NULL) {

  if(!is.null(city) & !is.null(country)) {
    city_data <- maps::world.cities %>%
      filter(name == city & country.etc == country)
    if(nrow(city_data) == 0) {
      msg <- paste("No city matches that name in the database.",
                   "Check the spelling (and for the country), or use",
                   "a coordinate pair instead")
      stop(msg, call. = FALSE)
    }
    if(nrow(city_data) > 1) {
      msg <- paste("More than one city matches. Can't have that.",
                   "Refine or perhaps provide a coordinate pair instead")
      print(city_data)
      stop(msg, call. = FALSE)
    }
    point <- city_data %>% sf::st_as_sf(coords = c("long", "lat"), crs = 4326)

  } else if(!is.null(x) & !is.null(y) & is.null(city)) {
    point <- sf::st_as_sf(data.frame(x, y), coords = c("x", "y"), crs = 4326)
  } else if(!is.null(city) & !is.null(x) | !is.null(y)) {
    stop("Don't provide both a city name and coordinates", call. = FALSE)
  }
  return(point)
}

