library(httr)
library(dplyr)
library(phsopendata) #available here: https://github.com/Public-Health-Scotland/phsopendata
library(tidyr)
library(magrittr)
library(zoo)

#resource id obtained from navigating to appropriate dataset on phs open data portal and coping id from browser

clinical_bmi_id <- "4a3daa0f-1580-4a59-ac9e-64d9a31a4429"

#get bmi data and extract relevant variables
clinical_BMI_dataset <- phsopendata::get_resource(res_id = clinical_bmi_id)
healthy_BMI <- clinical_BMI_dataset[c("SchoolYear", "CA", "ClinHealthyWeight")] %>%
  dplyr::filter(SchoolYear >= "2008/09")

healthy_BMI$CA[healthy_BMI$CA == "City of Edinburgh"] <- "Edinburgh, City of"
healthy_BMI$CA[healthy_BMI$CA == "Na h-Eileanan Siar"] <- "Eilean Siar"

#convert values column to three year rolled average 
rolled_avg_BMI <- healthy_BMI %>%
  dplyr::arrange(desc(CA)) %>% 
  dplyr::group_by(CA) %>% 
  dplyr::mutate("threeYrAvg" = 100*(zoo::rollmean(ClinHealthyWeight, k = 3, fill = NA))) %>% 
  dplyr::ungroup() %>%
  drop_na("threeYrAvg") #NAs introduced for first and last year when averages calculated

#get geography look-up codes
code_lookup_table <- read.csv("data_update/look_ups/code_lookup.csv") %>%
  select(CA, CPP) %>%
  distinct()

#join with lookup codes to get CPP name column based on code
p1_bmi_data <- left_join(rolled_avg_BMI, code_lookup_table, by = "CA") %>%
  arrange(CPP) %>%
  select(CPP, SchoolYear, threeYrAvg) %>%
  rename("Year" = SchoolYear, "value" = threeYrAvg) %>%
  select(CPP, Year, value)

#calculate scotland-wide values for each year (average of CPPs)
scotland_totals <- p1_bmi_data %>% 
  group_by(Year) %>%
  summarise(value = mean(value)) %>%
  mutate(CPP = "Scotland") %>%
  select(CPP, Year, value)

#incorporate scotland totals into CPP dataset (as per CPOP requirements)
final_bmi_data <- rbind(p1_bmi_data, scotland_totals) %>%
  mutate(Indicator = "Primary 1 Body Mass Index",
         Type = "Raw") %>%
  select(CPP, Year, Indicator, Type, value)

write.csv(final_bmi_data, file = "data_update/data/p1_body_mass_index_cpp.csv", row.names = FALSE)
