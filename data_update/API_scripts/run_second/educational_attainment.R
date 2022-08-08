#Querying statistics.gov.scot for mid-year estimate of the under-16 population

library(httr)
library(magrittr)
library(dplyr)
library(readr)

#read in sparql query from file
sparql <- readr::read_file("data_update/sparql/educational_attainment_iz.txt")

#read in geography codes to match IZ names to codes
codes <- codes <- read.csv("data_update/look_ups/code_lookup.csv") %>%
  select(IntZone, IntZoneName) %>%
  distinct() %>%
  rename("s02" = IntZone)

#request data from api
response <- httr::POST(
  url = "https://statistics.gov.scot/sparql.csv",
  body = list(query = sparql))

#parse response from api
data <- httr::content(response, as = "parsed", encoding = "UTF-8")

s02 <- left_join(data, codes, by = "s02") %>%
  select(s02, IntZoneName, Year, Score)

s12 <- data %>%
  group_by(CPP, Year) %>%
  summarise(value = mean(Score))

scotland_totals <- s12 %>%
  group_by(Year) %>%
  summarise(value = mean(value)) %>%
  mutate(CPP = "Scotland")

final_cpp_attainment <- rbind(s12, scotland_totals) %>%
  mutate(Indicator = "Attainment",
         Type = "Raw") %>%
  select(CPP, Year, Indicator, Type, value) %>%
  arrange(CPP, Year)

write.csv(final_cpp_attainment, "data_update/data/educational_attainment_cpp.csv", row.names = FALSE)
