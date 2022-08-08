##Obtains Children in Low Income Families, Relative Low Income from statxplore
#using the statxplorer package and reads in population data to calcute child poverty rate

library(statxplorer) #available here: https://github.com/houseofcommonslibrary/statxplorer
library(magrittr)
library(dplyr)

#provide key to api
statxplorer::load_api_key("data_update/API_keys/statxpl_apikey.txt")

#query statXplore api for LA level relative low income child poverty data (from json file)
results <- statxplorer::fetch_table(filename = "data_update/json/child_poverty_08_22.json")

#extract dataframe from response
data <- results$dfs$`Relative Low Income`

#rename variables
names(data) <- c("CPP", "Year", "Age", "Count")

#extract data for ages 0-15
child_poverty_totals <- data %>%
  dplyr::filter(Age == "Total") %>%
  select(!Age)

#fix alternative CPP names to match dahsboard naming practices
child_poverty_totals$CPP[child_poverty_totals$CPP == "City of Edinburgh"] <- "Edinburgh, City of"
child_poverty_totals$CPP[child_poverty_totals$CPP == "Na h-Eileanan Siar"] <- "Eilean Siar"
child_poverty_totals$CPP[child_poverty_totals$CPP == "Total"] <- "Scotland"

#read in denominator data and reformat years to match numerator (api output)
child_population <- read.csv("data_update/data/under_16_population.csv")
child_population$Year <- as.character(paste0(child_population$Year - 1,"/", substring(child_population$Year,3,4)))

#filter population data by those years which the API returned
timeseries_population <- child_population %>% 
  filter(Year %in% unique(child_poverty_totals$Year))

#join numerator and denominator data and calculate child poverty rate
child_poverty_rate <- dplyr::left_join(child_poverty_totals, timeseries_population, by = c("Year", "CPP")) %>%
  dplyr::mutate(value = Count/child_population*100,
         Indicator = "Child Poverty",
         Type = "Raw") %>%
  dplyr::select(CPP, Year, Indicator, Type, value)

write.csv(child_poverty_rate, "data_update/data/child_poverty_cpp.csv", row.names = FALSE)
