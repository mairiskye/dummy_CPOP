library(magrittr)
library(nomisr)
library(dplyr)

aps_datasets <- jsonlite::fromJSON(txt="https://www.nomisweb.co.uk/api/v01/dataset/def.sdmx.json?search=APSNEW")

employment_rate_id <- aps_datasets$structure$keyfamilies$keyfamily %>%
  filter(name$value == "annual population survey (variables (percentages))") %>%
  pull(id)

employment_metadata <- nomisr::nomis_get_metadata(employment_rate_id)

geography_type <- nomisr::nomis_get_metadata(employment_rate_id, concept = "GEOGRAPHY", type = "TYPE") %>%
  filter(grepl("local authorities: district", description.en)) %>%
  filter(grepl("2021", description.en)) %>%
  pull(id)

geography_area <- nomisr::nomis_get_metadata(employment_rate_id, concept = "GEOGRAPHY", type = geography_type) %>%
  filter(grepl("Falkirk", description.en)) %>%
  pull(parentCode)

employment_metadata_measure <- nomisr::nomis_get_metadata(employment_rate_id, concept = "MEASURES") %>%
  filter(description.en == "Variable") %>%
  pull(id)

employment_metadata_variable <- nomisr::nomis_get_metadata(employment_rate_id, concept = "VARIABLE") %>%
  filter(description.en == "Employment rate - aged 16-64") %>%
  pull(id)
employment_metadata_freq <- nomisr::nomis_get_metadata(employment_rate_id, concept = "FREQ") %>%
  filter(description.en == "Annually") %>%
  pull(id)

#NOTE! freq = a returns annual data for all available periods (financial, calendar etc.),
# however freq=A (which is the id pulled programatically from the metadata) returns only calendar. We need Apr-Mar data so this should not be used.
employment_rate_uri <- paste0("https://www.nomisweb.co.uk/api/v01/dataset/",
                              employment_rate_id,
                              ".data.csv?geography=",
                              geography_area,
                              geography_type,
                              "&freq=a&measures=",
                              employment_metadata_measure,
                              "&variable=",
                              employment_metadata_variable,
                              "&time=2008,latest&select=,DATE_NAME,GEOGRAPHY_NAME,OBS_VALUE",
                              sep="")
