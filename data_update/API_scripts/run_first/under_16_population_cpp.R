#Querying statistics.gov.scot for mid-year estimate of the under-16 population

library(httr)
library(magrittr)
library(dplyr)

#read in sparql query from file
sparql <- read_file("data_update/sparql/population_under_16_cpp.txt")

#request data from api
response <- httr::POST(
  url = "https://statistics.gov.scot/sparql.csv",
  body = list(query = sparql))

#parse response from api
data <- httr::content(response, as = "parsed", encoding = "UTF-8")

scotland_totals <- data %>%
  group_by(Year) %>%
  summarise(child_population = sum(child_population)) %>%
  mutate(CPP = "Scotland")

data_with_totals <- rbind(data, scotland_totals)

data_with_totals$CPP[data_with_totals$CPP == "City of Edinburgh"] <- "Edinburgh, City of"
data_with_totals$CPP[data_with_totals$CPP == "Na h-Eileanan Siar"] <- "Eilean Siar"

write.csv(data_with_totals, "data_update/data/under_16_population.csv", row.names = FALSE)
