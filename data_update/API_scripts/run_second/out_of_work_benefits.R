#Obtains Benefit Combination Totals for those out of work from statxplore
#calculates rates using NRS MYE working age population

library(statxplorer) #available here: https://github.com/houseofcommonslibrary/statxplorer
library(magrittr)
library(dplyr)

statxplorer::load_api_key("data_update/API_keys/statxpl_apikey.txt")

#UPDATE ME
#data from 2019 onwards :
results_recent <- statxplorer::fetch_table(filename = "data_update/json/oowb_08_22.json")

#UPDATE ME
#data from 2013-2018:
results_historic <- statxplorer::fetch_table(filename = "data_update/json/oowb_historic_08_22.json")

recent_data <- results_recent$dfs$`Benefit Combinations New` %>%
  rename("Benefit Combinations" = `Benefit Combinations New`)

historic_data <- results_historic$dfs$`Benefit Combinations`

combined_data <- rbind(recent_data, historic_data)

oowb_count <- dplyr::filter(combined_data, 
                                combined_data[3] == "Total", 
                                grepl("May", Quarter)) %>%
  select(!`Benefit Combinations (Out of Work)`) 

names(oowb_count)[1:3] <- c("CPP", "Year", "benefit_recipient_count")

#convert year format e.g. from May-19 to 2019
oowb_count$Year <- gsub("May-", "20", oowb_count$Year)

oowb_count$Year <- as.numeric(oowb_count$Year)

oowb_count$CPP[oowb_count$CPP == "City of Edinburgh"] <- "Edinburgh, City of"
oowb_count$CPP[oowb_count$CPP == "Na h-Eileanan Siar"] <- "Eilean Siar"
oowb_count$CPP[oowb_count$CPP == "Total"] <- "Scotland"

#read in denominator data (api output)
population <- read.csv("data_update/data/working_age_population_cpp.csv")
population$Year <- as.numeric(population$Year)

oowb_proportions <- left_join(oowb_count, population, by = c("Year", "CPP")) %>%
  na.omit() %>%
  mutate(value = benefit_recipient_count/working_age_pop*100,
         Indicator = "Out of Work Benefits",
         Type = "Raw") %>%
  select(CPP, Year, Indicator, Type, value) %>%
  arrange(CPP, Year)

write.csv(oowb_proportions, "data_update/data/out_of_work_benefits_cpp.csv", row.names = FALSE)
