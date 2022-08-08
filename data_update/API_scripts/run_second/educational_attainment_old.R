#querying Educational Attainment data from statistics.gov.scot with a POST method

library(httr) 
library(magrittr)
library(dplyr)

#import lookup table to match geographical area names to s-codes
codes <- read.csv("data_update/look_ups/code_lookup.csv") %>%
  dplyr::select(DataZone, IntZone, CA, FG) %>%
  dplyr::rename("DZCode" = DataZone) %>%
  dplyr::rename("IZCode" = IntZone) %>%
  dplyr::rename("CPPCode" = CA)

#make post request to statistics.gov.scot using SPARQL query
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

#parse response to get data
data <- httr::content(resp, as = "parsed", encoding = "UTF-8")

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
data_with_codes_and_metadata <- dplyr::left_join(data, codes, by = "DZCode") %>%
  dplyr::mutate(Indicator = "Attainment") %>%
  dplyr::mutate(Type = "Raw")

#extract data for different geography zones into seperate objects
 #(s01 is the prefix for a datazone, s02 is the prefix for intermediate zones)
s01 <- dplyr::filter(data, grepl("S01", DZCode)) %>%
  dplyr::mutate(Indicator = "Attainment", Type = "Raw")

s02 <- dplyr::filter(data, grepl("S02", DZCode)) %>%
  dplyr::select(!CPP) %>%
  dplyr::rename("IZCode" = DZCode, "IZName" = DZName, "CPP" = IZName) %>%
  dplyr::mutate(Indicator = "Attainment", Type = "Raw")

#get CPP level data by aggregating intermediate zone data (average)
s12_without_totals <- s02 %>%
  dplyr::group_by(CPP, Year) %>%
  dplyr::summarise(value = mean(value)) %>%
  dplyr::ungroup() %>%
  dplyr::select(CPP, Year, value)

#get scotland wide figures by aggregating CPP data to yearly averages
scotland_totals <- s12_without_totals %>%
  dplyr::group_by(Year) %>%
  dplyr::summarise(value = mean(value)) %>%
  dplyr::mutate(CPP = "Scotland") %>%
  dplyr::select(CPP, Year, value)

#combine CPP data with the scotland wide totals (as per CPOP practice)
s12 <- rbind(s12_without_totals, scotland_totals) %>%
  dplyr::mutate(Indicator = "Attainment", Type = "Raw") %>%
  dplyr::select(CPP, Year, Indicator, Type, value) %>%
  dplyr::arrange(CPP)
  
write.csv(s01, file = "data_update/data/educational_attainment_dz.csv", row.names = FALSE)
write.csv(s02, file = "data_update/data/educational_attainment_iz.csv", row.names = FALSE)
write.csv(s12, file = "data_update/data/educational_attainment_cpp.csv", row.names = FALSE)

