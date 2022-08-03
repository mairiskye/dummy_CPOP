library(statxplorer)
library(magrittr)
library(dplyr)

child_population <- read.csv("data_update/data/children_population.csv")
statxplorer::load_api_key("data_update/txt/statxpl_apikey.txt")

child_population$Year <- as.character(paste0(child_population$Year - 1,"/", child_population$Year - 2000))
child_population$children_population <- as.numeric(child_population$children_population)

#query statXplore api fo LA level relative low income child poverty data (from json file)
results <- statxplorer::fetch_table(filename = "data_update/json/child_poverty_la.json")
#extract dataframe from response
data <- results$dfs$`Relative Low Income`
#rename variables
names(data) <- c("CPP", "Year", "Age", "Count")
#extract data for ages 0-15
extract_age <- data %>%
  dplyr::filter(Age == c("0-4", "5-10", "11-15"))

#count total children in poverty by aggregating age
child_pov_count <- extract_age %>%
  group_by(CPP, Year) %>%
  summarise(child_poverty_count = sum(Count)) %>%
  ungroup()

child_pov_count$CPP[child_pov_count$CPP == "City of Edinburgh"] <- "Edinburgh, City of"
child_pov_count$CPP[child_pov_count$CPP == "Na h-Eileanan Siar"] <- "Eilean Siar"
child_pov_count$CPP[child_pov_count$CPP == "Total"] <- "Scotland"

child_pov_proportions <- left_join(child_pov_count, child_population, by = c("Year", "CPP")) %>%
  na.omit() %>%
  mutate(value = child_poverty_count/children_population*100,
         Indicator = "Child Poverty",
         Type = "Raw") %>%
  select(CPP, Year, Indicator, Type, value)

write.csv(child_pov_proportions, "data_update/data/child_poverty_cpp.csv", row.names = FALSE)
