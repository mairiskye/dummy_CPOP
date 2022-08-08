#Querying statistics.gov.scot for mid-year estimate of the under-16 population

library(httr)
library(magrittr)
library(dplyr)

#read in sparql query from file
sparql <- read_file("data_update/sparql/educational_attainment_dz.txt")

#request data from api
response <- httr::POST(
  url = "https://statistics.gov.scot/sparql.csv",
  body = list(query = sparql))

#parse response from api
data <- httr::content(response, as = "parsed", encoding = "UTF-8")

write.csv(data, "data_update/data/educational_attainment.csv", row.names = FALSE)
