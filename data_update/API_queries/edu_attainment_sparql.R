#querying Educational Attainment data from statistics.gov.scot with a POST method

library(httr) 
library(magrittr)
library(dplyr)

#import lookup table to match geographical area names to s-codes
codes <- read.csv("data_update/look_ups/code_lookup.csv") %>%
  select(DataZone, IntZone, CA, FG) %>%
  rename("DZCode" = DataZone) %>%
  rename("IZCode" = IntZone) %>%
  rename("CPPCode" = CA)

#make api request
resp <- httr::POST(
  url = "https://statistics.gov.scot/sparql.csv",
  body = list(query = "select  ?score ?years ?DZCode ?DZName ?IZName ?councilName 
           where { 
             ?data <http://purl.org/linked-data/cube#dataSet> <http://statistics.gov.scot/data/educational-attainment-of-school-leavers>. 
             ?refPeriod <http://www.w3.org/2000/01/rdf-schema#label> ?years.
             ?data <http://purl.org/linked-data/sdmx/2009/dimension#refArea> ?refArea.
             ?data <http://purl.org/linked-data/sdmx/2009/dimension#refPeriod> ?refPeriod.
             ?refArea <http://www.w3.org/2004/02/skos/core#notation> ?DZCode.
  			 ?data <http://purl.org/linked-data/cube#measureType> ?measureType.
  			 ?refArea <http://www.w3.org/2000/01/rdf-schema#label> ?DZName.
  			 ?refArea <http://statistics.data.gov.uk/def/statistical-geography#parentcode> ?IZparentCode.
  			 ?IZparentCode <http://www.w3.org/2000/01/rdf-schema#label> ?IZName.
 			 ?IZparentCode <http://statistics.data.gov.uk/def/statistical-geography#parentcode> ?council.
  			 ?council <http://www.w3.org/2000/01/rdf-schema#label> ?councilName.
             ?data ?measureType ?score.}"))

#parse response
data <- content(resp, as = "parsed")

#rename columns to ultimately match master data format
names(data)[names(data) == "councilName"] <- "CPP"
names(data)[names(data) == "years"] <- "Year"
names(data)[names(data) == "score"] <- "value"

#rename councils which do not match CPOP council names
data$CPP[data$CPP == "City of Edinburgh"] <- "Edinburgh, City of"
data$CPP[data$CPP == "Na h-Eileanan Siar"] <- "Eilean Siar"
data$IZName[data$IZName == "City of Edinburgh"] <- "Edinburgh, City of"
data$IZName[data$IZName == "Na h-Eileanan Siar"] <- "Eilean Siar"

#add area codes (these are more appropriate for filtering since area names aren't necessarily exclusive)
data_with_codes_and_metadata <- left_join(data, codes, by = "DZCode") %>%
  mutate(Indicator = "Attainment") %>%
  mutate(Type = "Raw")

#subset attainment dataset for data zone level data only
 #(s01 is the prefix for a datazone, s02 is the prefix for intermediate zones)
s01 <- dplyr::filter(data, grepl("S01", DZCode)) %>%
  mutate(Indicator = "Attainment", Type = "Raw")

s02 <- dplyr::filter(data, grepl("S02", DZCode)) %>%
  select(!CPP) %>%
  rename("IZCode" = DZCode, "IZName" = DZName, "CPP" = IZName) %>%
  mutate(Indicator = "Attainment", Type = "Raw")

#summarise intermediate zone data by council area (average)
s12_without_totals <- s02 %>%
  group_by(CPP, Year) %>%
  summarise(value = mean(value)) %>%
  ungroup() %>%
  select(CPP, Year, value)

scotland_totals <- s12_without_totals %>%
  group_by(Year) %>%
  summarise(value = mean(value)) %>%
  mutate(CPP = "Scotland") %>%
  select(CPP, Year, value)

s12 <- rbind(s12_without_totals, scotland_totals) %>%
  mutate(Indicator = "Attainment", Type = "Raw") %>%
  select(CPP, Year, Indicator, Type, value) %>%
  arrange(CPP)
  
write.csv(s01, file = "data_update/data/edu_attainment_dz_data.csv", row.names = FALSE)
write.csv(s02, file = "data_update/data/edu_attainment_iz_data.csv", row.names = FALSE)
write.csv(s12, file = "data_update/data/edu_attainment_cpp_data.csv", row.names = FALSE)

