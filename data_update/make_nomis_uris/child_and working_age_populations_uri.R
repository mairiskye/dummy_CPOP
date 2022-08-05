#Obtains working age population and 0-15 year old population from NRS mid-year-estimates via nomis

library(httr)
library(magrittr)
library(dplyr)
library(nomisr) #available here: https://github.com/ropensci/nomisr

#GET METADATA -------------------------------------------

#search all nomis api datasets using a search term: PESTNEW
#note PESTNEW is the API reference given on the nomis webpage for the population projcetions and estimates dataset
MYE_search <- jsonlite::fromJSON(txt="https://www.nomisweb.co.uk/api/v01/dataset/def.sdmx.json?search=PESTNEW")

#extract dataset id from above api queries
MYE_code <- MYE_search$structure$keyfamilies$keyfamily %>%
  pull(id)

#get metadata for this dataset
MYE_metadata <- nomisr::nomis_get_metadata(MYE_code)

#GET UNIQUE DATASET PARAMETERS FROM METADATA -------------------
#both working age and childrens population have the same parameters EXCEPT for 
# age band id

geography_type_param <- nomisr::nomis_get_metadata(MYE_code, concept = "GEOGRAPHY", type = "TYPE") %>%
  filter(grepl("local authorities: district", description.en)) %>%
  filter(grepl("2021", description.en)) %>%
  pull(id)

#search all local authorities using any which falls in Scotland and extract parent code
geography_area_param <- nomisr::nomis_get_metadata(MYE_code, concept = "GEOGRAPHY", type = geography_type_param) %>%
  filter(grepl("Falkirk", description.en)) %>%
  pull(parentCode)

#only one frequency, no need to extract an id
freq_param <- nomisr::nomis_get_metadata(MYE_code, concept = "FREQ")

sex_param <- nomisr::nomis_get_metadata(MYE_code, concept = "SEX") %>%
  filter(grepl("Total", description.en)) %>%
  pull(id)

#get id for 16-64 age bracket
age_param <- nomisr::nomis_get_metadata(MYE_code, concept = "AGE") %>%
  filter(grepl("Aged 16 - 64", description.en)) %>%
  pull(id)

#get id for 0-15 age bracket 
children_age_param <- nomisr::nomis_get_metadata(MYE_code, concept = "AGE") %>%
  filter(grepl("Aged 0 - 15", description.en)) %>%
  pull(id)

measures_param <- nomisr::nomis_get_metadata(MYE_code, concept = "MEASURES") %>%
  filter(grepl("value", description.en)) %>%
  pull(id)

#a range of times will be queried so this is an exploratory step to see what timeseries is available according to the metadata
time_param <- nomisr::nomis_get_metadata(MYE_code, concept = "TIME")

#CREATE API URIs------------------------------

#embed relevant paramaters for working age population within api uri to use in GET request
working_age_population_uri <- paste("https://www.nomisweb.co.uk/api/v01/dataset/",
                                      MYE_code,
                                      ".data.csv?geography=",
                                      geography_area_param,
                                      geography_type_param,
                                      "&measures=",
                                      measures_param,
                                      "&sex=",
                                      sex_param,
                                      "&age=",
                                      age_param,
                                      "&time=2008,latest&select=DATE,GEOGRAPHY_NAME,OBS_VALUE",
                                      sep="")

#as above but for children (0-15)
child_population_uri <- paste("https://www.nomisweb.co.uk/api/v01/dataset/",
                          MYE_code,
                          ".data.csv?geography=",
                          geography_area_param,
                          geography_type_param,
                          "&measures=",
                          measures_param,
                          "&sex=",
                          sex_param,
                          "&age=",
                          children_age_param,
                          "&time=2008,latest&select=DATE,GEOGRAPHY_NAME,OBS_VALUE",
                          sep="")
