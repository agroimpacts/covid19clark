library(lubridate)
library(dplyr)

dvec <- paste0("03-", sprintf("%02i", 1:28), "-2020")

daily_reports <- lapply(dvec, function(x) {
  covid19clark::get_jhu_daily(download_date = x, write = FALSE)
})
daily_reports_all <- do.call(rbind, daily_reports) %>% arrange(date, country)
# daily_reports_all[1, c("fips", "admin2", "key")] <- "NA"

readr::write_csv(daily_reports_all,
                 path = here::here("inst/extdata/covid19_daily_reports.csv"))

# # column matching vector
# varpats <- tibble(
#   pat = c("fips", "admin2", "prov", "country", "key", "update", "long", "lat",
#           "confirm", "death", "recover", "active"),
#   replace = c("fips", "admin2", "prov", "country",  "key", "date", "x", "y",
#               "cases", "deaths", "recovered", "active")
# )
# daily_reports <- lapply(dvec, function(x) {  # x <- dvec[1]
#
#   # read in data
#   path <- paste0("https://github.com/CSSEGISandData/COVID-19/raw/master/",
#                  "csse_covid_19_data/csse_covid_19_daily_reports/", x,".csv")
#   dat <- readr::read_csv(path) %>% rename_all(tolower)   # lower case
#
#   # match and replace varying column names
#   newnames <- sapply(tolower(colnames(dat)), function(x) {
#     present <- str_detect(string = x, varpats$pat)
#     ifelse(any(present), varpats$replace[which(present)], NA)
#   }) %>% unname
#   colnames(dat) <- newnames
#
#   # for earlier dataset, if columns are missing, add them for easy row binding
#   outnames <- !varpats$replace %in% colnames(dat)
#   if(any(outnames)) {
#     missing_col_names <- varpats$replace[which(outnames)]
#     newcols <- matrix(NA, ncol = length(which(outnames)), nrow = nrow(dat)) %>%
#       data.frame() %>% as_tibble() %>% rename_all(vars(missing_col_names))
#     dat <- bind_cols(dat, newcols)
#   }
#   dat <- dat %>% dplyr::select(!!varpats$replace)
#
#   # fix bad dates
#   if(is.character(dat$date)) {
#     dat <- dat %>% mutate(date = as_date(mdy_hm(date)))
#   } else {
#     dat <- dat %>% mutate(date = as_date(date))
#   }
#   return(dat)
# })
# daily_reports_all <- do.call(rbind, daily_reports) %>%
#   dplyr::select(-active)


# daily_reports_all %>%
#   filter(country == "US" & prov == "New York") %>%
#   filter(date == "2020-03-24") %>%
#   summarize(confirmed = sum(cases))
#   pull(date)


