#Querying statistics.gov.scot for mid-year estimate of the under-16 population

library(httr)
library(magrittr)
library(dplyr)
library(readr)

#read in sparql query from file
sparql <- read_file("data_update/sparql/population_working_age_cpp.txt")

#request data from api
response <- httr::POST(
  url = "https://statistics.gov.scot/sparql.csv",
  body = list(query = sparql))

#parse response from api
data <- httr::content(response, as = "parsed", encoding = "UTF-8")

#calculate scotland total for each year
scotland_totals <- data %>%
  group_by(Year) %>%
  summarise(working_age_population = sum(working_age_population)) %>%
  mutate(CPP = "Scotland")

#combine CPP data and Scotland totals
data_with_totals <- rbind(data, scotland_totals)

data_with_totals$CPP[data_with_totals$CPP == "City of Edinburgh"] <- "Edinburgh, City of"
data_with_totals$CPP[data_with_totals$CPP == "Na h-Eileanan Siar"] <- "Eilean Siar"

write.csv(data_with_totals, "data_update/data/working_age_population_cpp.csv", row.names = FALSE)
