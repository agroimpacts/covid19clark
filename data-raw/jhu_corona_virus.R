# Download JHU Corona virus data
# source: https://github.com/CSSEGISandData/COVID-19
# code adapted from: https://github.com/RamiKrispin/coronavirus
`%>%` <- magrittr::`%>%`
f <- here::here("inst/extdata/covid19_ts.csv")
cases <- covid19clark::get_jhu_ts(write = TRUE, filepath = f)

