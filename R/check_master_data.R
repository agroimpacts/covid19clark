system("git checkout master")
system("git fetch -p origin")
system("git checkout devel")
system("git checkout master -- data/us_cases_daily.rda")

