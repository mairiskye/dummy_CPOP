##Obtains Children in Low Income Families, Relative Low Income from statxplore
#     using the statxplorer package

library(statxplorer) #available here: https://github.com/houseofcommonslibrary/statxplorer
library(magrittr)
library(dplyr)

#provide key to api
statxplorer::load_api_key("data_update/API_keys/statxpl_apikey.txt")

#UPDATE ME
#query statXplore api fo LA level relative low income child poverty data (from json file)
results <- statxplorer::fetch_table(filename = "data_update/json/child_poverty_07_22.json")

#extract dataframe from response
data <- results$dfs$`Relative Low Income`

#rename variables
names(data) <- c("CPP", "Year", "Age", "Count")

#extract data for ages 0-15
extract_age <- data %>%
  dplyr::filter(Age == c("0-4", "5-10", "11-15"))

#count total children in poverty by summing age bands
child_pov_count <- extract_age %>%
  dplyr::group_by(CPP, Year) %>%
  dplyr::summarise(child_poverty_count = sum(Count)) %>%
  dplyr::ungroup()

#fix alternative CPP names to match dahsboard naming practices
child_pov_count$CPP[child_pov_count$CPP == "City of Edinburgh"] <- "Edinburgh, City of"
child_pov_count$CPP[child_pov_count$CPP == "Na h-Eileanan Siar"] <- "Eilean Siar"
child_pov_count$CPP[child_pov_count$CPP == "Total"] <- "Scotland"

#read in denominator data and reformat years to match numerator (api output)
child_population <- read.csv("data_update/data/children_population_cpp.csv")
child_population$Year <- as.character(paste0(child_population$Year - 1,"/", child_population$Year - 2000))
child_population$children_population <- as.numeric(child_population$children_population)

#join numerator and denominator data and calculate child poverty rate
child_pov_proportions <- dplyr::left_join(child_pov_count, child_population, by = c("Year", "CPP")) %>%
  na.omit() %>%
  dplyr::mutate(value = child_poverty_count/children_population*100,
         Indicator = "Child Poverty",
         Type = "Raw") %>%
  dplyr::select(CPP, Year, Indicator, Type, value)

write.csv(child_pov_proportions, "data_update/data/child_poverty_cpp.csv", row.names = FALSE)
