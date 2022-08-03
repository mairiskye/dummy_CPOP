library(httr)
library(dplyr)
library(phsopendata)
library(tidyr)

res_id <- "e9f8d10c-9c06-4e77-a0f5-70ff14af25a4"
BMI_dataset <- phsopendata::get_resource(res_id = res_id)
healthy_BMI <- BMI_dataset[c("SchoolYear", "CA", "EpiHealthyWeight")]

rolled_avg_BMI <- healthy_BMI %>%
  dplyr::arrange(desc(CA)) %>% 
  dplyr::group_by(CA) %>% 
  dplyr::mutate("threeYrAvg" = 100*(zoo::rollmean(EpiHealthyWeight, k = 3, fill = NA))) %>% 
  dplyr::ungroup() %>%
  drop_na("threeYrAvg")

code_lookup_table <- read.csv("data_update/look_ups/code_lookup.csv") %>%
  select(CA, CPP) %>%
  distinct()

p1_bmi_data <- left_join(rolled_avg_BMI, code_lookup_table, by = "CA") %>%
  arrange(CPP) %>%
  select(CPP, SchoolYear, threeYrAvg) %>%
  rename("Year" = SchoolYear, "value" = threeYrAvg) %>%
  select(CPP, Year, value)

scotland_totals <- p1_bmi_data %>% 
  group_by(Year) %>%
  summarise(value = mean(value)) %>%
  mutate(CPP = "Scotland") %>%
  select(CPP, Year, value)

final_bmi_data <- rbind(p1_bmi_data, scotland_totals) %>%
  mutate(Indicator = "Primary 1 Body Mass Index",
         Type = "Raw") %>%
  select(CPP, Year, Indicator, Type, value)
  

write.csv(final_bmi_data, file = "data_update/data/p1_bmi_data.csv", row.names = FALSE)
