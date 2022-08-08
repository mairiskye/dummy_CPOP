library(httr)
library(dplyr)
library(magrittr)
library(readr)

crime_rate_sparql <- read_file("data_update/sparql/crime_rate_cpp.txt")

crime_rate_resp <- httr::POST(
  url = "https://statistics.gov.scot/sparql.csv",
  body = list(query = crime_rate_sparql))

crime_rate <- content(crime_rate_resp, as = "parsed", encoding = "UTF-8") %>%
  select(!Code)

final_crime_data <- crime_rate %>%
  mutate(Indicator = "Crime",
         Type = "Raw") %>%
  select(CPP, Year, Indicator, Type, value) %>%
  arrange(CPP, Year)
  
write.csv(final_crime_data, "data_update/data/crime_rate_cpp.csv", row.names = FALSE)
