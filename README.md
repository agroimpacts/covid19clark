covid19clark
================

A very limited `R` package (with no functions and just one vignette)
that can be used to get daily updates of changes in the distribution of
COVID-19 within a limited geographic extent centered on a city of
interest, in this case Worcester, MA, the home of Clark University.

The repo contains code to pull daily data from the Johns Hopkins
University [COVID-19
repository](https://github.com/CSSEGISandData/COVID-19/), and adapts
code from Rami Krispin’s
[`coronavirus`](https://github.com/RamiKrispin/coronavirus) package,
which has a very nice interactive, global dashboard.

This packages was made to highlight the regional change, and to try
resolve some of the county level detail available in source datasets, to
track finer spatial changes.

**Last update**: 2020-03-17 20:02:27
<img src="vignettes/figures/case_maps.png" width="100%" />

## Notes

  - **I am not an epidemiologist, so this information should not be
    taken as authoritative. There may be flaws in the code or data
    handling that give rise to misleading results.**
  - If the map is correct, it is nevertheless misleading in that the
    number of cases is almost certainly an underestimate, as US testing
    has been very limited. This statement should be uncontroversial. To
    support that claim,
    [here](https://www.cdc.gov/coronavirus/2019-ncov/cases-updates/testing-in-us.html?CDC_AA_refVal=https%3A%2F%2Fwww.cdc.gov%2Fcoronavirus%2F2019-ncov%2Ftesting-in-us.html)
    is the CDC’s page on testing rates.
    [Here](https://www.businessinsider.com/coronavirus-testing-covid-19-tests-per-capita-chart-us-behind-2020-3?op=1)
    is a comparison of the US testing rate relative to other countries.
  - The county-level map (top left) consists of incomplete records and
    sum to less than reported totals. It is unclear whether county level
    data are being or will continue to be reported through to the
    source. You will note that this map shows no cases for Connecticut,
    because the reported cases there are only given at the state level.
  - For Massachusetts, better county-level information is available in
    the summary reports from the Department of Public Health (DPH),
    found
    [here](https://www.mass.gov/info-details/covid-19-cases-quarantine-and-monitoring).
    The totals seems to match the JHU source data, but the state reports
    most cases as presumptive, not confirmed, which is how they are
    described in the JHU data. ***We are working on ingesting the DPH’s
    data***, as soon as we get a scraping script set up.  
  - The state-level maps should provide the correct numbers.
  - The bubble plots are hard to read, so we are working on improving
    those also.

## Installation

If you want to see the vignette and plot using data from the most recent
commit:

``` r
devtools::install_github(build_vignettes = TRUE)
```
