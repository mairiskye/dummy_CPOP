#Obtains 0-15 year old and working age (16-64) population from NRS mid-year-estimates via nomis

library(httr)
library(magrittr)
library(dplyr)

#GET WORKING AGE POPULATION DATA---------------------------

#query and parse nomis api (working age population data)
query_wa_population <- httr::GET("https://www.nomisweb.co.uk/api/v01/dataset/NM_31_1.data.csv?geography=2013265931TYPE432&measures=20100&sex=7&age=22&time=2008,latest&select=DATE,GEOGRAPHY_NAME,OBS_VALUE")
wa_population <- content(query_wa_population, as = "parsed", type = "text/csv") %>%
  as_tibble() %>%
  na.omit()

wa_population$GEOGRAPHY_NAME[wa_population$GEOGRAPHY_NAME == "City of Edinburgh"] <- "Edinburgh, City of"
wa_population$GEOGRAPHY_NAME[wa_population$GEOGRAPHY_NAME == "Na h-Eileanan Siar"] <- "Eilean Siar"

scotland_totals <- wa_population %>%
  group_by(DATE) %>%
  summarise(OBS_VALUE = sum(OBS_VALUE)) %>%
  mutate(GEOGRAPHY_NAME = "Scotland")

wa_population_with_totals <- rbind(wa_population, scotland_totals)
names(wa_population_with_totals) <- c("Year", "CPP", "working_age_pop")

write.csv(wa_population_with_totals, "data_update/data/working_age_population_cpp.csv", row.names = FALSE)

#GET CHILDRENS POPULATION DATA-----------------------------

query_children_population <- httr::GET("https://www.nomisweb.co.uk/api/v01/dataset/NM_31_1.data.csv?geography=2013265931TYPE432&measures=20100&sex=7&age=24&time=2008,latest&select=DATE,GEOGRAPHY_NAME,OBS_VALUE")
children_population <- content(query_children_population, as = "parsed", type = "text/csv") %>%
  as_tibble() %>%
  na.omit()

children_population$GEOGRAPHY_NAME[children_population$GEOGRAPHY_NAME == "City of Edinburgh"] <- "Edinburgh, City of"
children_population$GEOGRAPHY_NAME[children_population$GEOGRAPHY_NAME == "Na h-Eileanan Siar"] <- "Eilean Siar"

scotland_totals_children <- children_population %>%
  group_by(DATE) %>%
  summarise(OBS_VALUE = sum(OBS_VALUE)) %>%
  mutate(GEOGRAPHY_NAME = "Scotland")

children_population_with_totals <- rbind(children_population, scotland_totals_children) %>%
  arrange(GEOGRAPHY_NAME, DATE)
names(children_population_with_totals) <- c("Year", "CPP", "children_population")

write.csv(children_population_with_totals, "data_update/data/children_population_cpp.csv", row.names = FALSE)
