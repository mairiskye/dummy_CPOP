#Creates csv of healthy birthweight proportions at CPP level using PHS's phsopendata package

library(phsopendata) #available here: https://github.com/Public-Health-Scotland/phsopendata
library(magrittr)
library(dplyr)

#id obtained by locating dataset in opendata phs site and copying id from url in browser
appro_bweight_id <- "a5d4de3f-e340-455f-b4e4-e26321d09207"

#obtain dataset using phsopendata package (not on CRAN)
appro_bweight_dtaset <- phsopendata::get_resource(res_id = appro_bweight_id)

#extract CPP level data from 2008/09 onwards and trim unecessary columns
clean_bweight_data <- appro_bweight_dtaset[grep("S12", appro_bweight_dtaset$CA),] %>%
  dplyr::filter(FinancialYear >= "2008/09") %>%
  dplyr::select(FinancialYear, CA, BirthweightForGestationalAge, Livebirths) %>%
  dplyr::group_by(FinancialYear, CA, BirthweightForGestationalAge) %>%
  dplyr::summarise(Births = sum(Livebirths))

#calculate total live births
all_births <- clean_bweight_data %>%
  dplyr::group_by(FinancialYear, CA) %>%
  dplyr::summarise(AllLiveBirths = sum(Births))

#extract number of births considered 'appropriate' weight
approp_births <- clean_bweight_data %>%
  dplyr::filter(BirthweightForGestationalAge == "Appropriate") %>%
  dplyr::select(FinancialYear, CA, Births)
names(approp_births)[3] <- "AppropriateWeightCount"

#join birth totals and 'Appropiate weight' aggregate and calculate proportions
all_bweight_data <- dplyr::left_join(all_births, approp_births) %>%
  dplyr::mutate(AppropriateWeightProportion = AppropriateWeightCount/AllLiveBirths * 100) %>%
  dplyr::select(FinancialYear, CA, AppropriateWeightProportion)

#extract only council area codes and names from lookup table
code_lookup <- read.csv("data_update/look_ups/code_lookup.csv") %>%
 dplyr::select(CPP, CA) %>%
  dplyr::distinct()

#match council names to council codes (as per standard indicator format)
bweight_without_totals <- left_join(all_bweight_data, code_lookup, "CA") %>%
  dplyr::select(!CA) %>%
  dplyr::rename("Year" = FinancialYear,
         "value" = AppropriateWeightProportion) %>%
  dplyr::select(CPP, Year, value)

#create scotland-wide totals by aggregating CPP data by year (taking an average)
scotland_totals <- bweight_without_totals %>%
  dplyr::group_by(Year) %>%
  dplyr::summarise(value = mean(value)) %>%
  dplyr::mutate(CPP = "Scotland") %>%
  dplyr::select(Year, value, CPP)

#join CPP and scotland_wide data and create master data format
final_bweight_data <- rbind(bweight_without_totals, scotland_totals) %>%
  dplyr::mutate(Indicator = "Healthy Birthweight",
         Type = "Raw") %>%
  dplyr::select(CPP, Year, Indicator, Type, value)

#fix alterntive CPP names to match CPOP naming practices
final_bweight_data$CPP[final_bweight_data$CPP == "City of Edinburgh"] <- "Edinburgh, City of"
final_bweight_data$CPP[final_bweight_data$CPP == "Na h-Eileanan Siar"] <- "Eilean Siar"

#save dataframe as csv in "data" folder
write.csv(final_bweight_data, "data_update/data/healthy_birthweight_cpp.csv", row.names = FALSE)
