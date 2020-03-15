covid19clark
================

A very limited `R` package (with no functions and just one vignette)
that can be used to get daily updates of changes in the distribution of
COVID-19 within a limited geographic extent centered on a city of
interest, in this case Worcester, MA, the home of Clark University.

The repo contains code to pulls daily data from the Johns Hopkins
University [COVID-19
repository](https://github.com/CSSEGISandData/COVID-19/), and adapts
code from Rami Krispin’s
[`coronavirus`](https://github.com/RamiKrispin/coronavirus) package,
which has a very nice interactive, global dashboard.

This packages was made to highlight the regional change, and to try
resolve some of the county level detail available in source datasets, to
track finer spatial changes.

**Last update**: 2020-03-15 16:07:59
<img src="vignettes/figures/case_maps.png" width="100%" />

## Data notes

  - The county-level map (top left) consists of incomplete records and
    sum to less than reported totals. It is unclear whether county level
    data are being or will continue to be reported through to the
    source. You will note that this map shows no cases for Connecticut,
    because the reported cases there are only given at the state level.
  - For Massachusetts, better county-level information is available in
    the summary reports from the Department of Public Health, found
    [here](https://www.mass.gov/info-details/covid-19-cases-quarantine-and-monitoring).
    The totals seems to match the JHU source data, but the state reports
    most cases as presumptive, not confirmed, which is how they are
    described in the JHU data.
  - The state-level maps should provide the correct numbers.
