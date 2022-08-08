library(magrittr)

#UPDATE when new .json files are added with format "mm_yy"
child_poverty <- "07_22"
oowb <- "08_22"
oowb_historic <- "08_22"

#in API scripts, find and replace "mm_yy" with date that refers to up-to-date .json 
readLines('data_update/API_scripts/run_second/child_poverty.R') %>%
  gsub("child_poverty_[0-9]{2}_[0-9]{2}", paste0("child_poverty_", child_poverty), .) %>%
  writeLines("data_update/API_scripts/run_second/child_poverty.R")

readLines('data_update/API_scripts/run_second/out_of_work_benefits.R') %>%
  gsub("historic_[0-9]{2}_[0-9]{2}", paste0("historic_",oowb_historic), .) %>%
  writeLines("data_update/API_scripts/run_second/out_of_work_benefits.R")

readLines('data_update/API_scripts/run_second/out_of_work_benefits.R') %>%
  gsub("oowb_[0-9]{2}_[0-9]{2}", paste0("oowb_",oowb), .) %>%
  writeLines("data_update/API_scripts/run_second/out_of_work_benefits.R")
