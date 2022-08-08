library(magrittr)
library(dplyr)
library(stringr)
library(zoo)

empl_rate <- httr::GET("https://www.nomisweb.co.uk/api/v01/dataset/NM_17_5.data.csv?geography=2013265931TYPE432&freq=a&measures=20599&variable=45&time=2008,latest&select=,DATE_NAME,GEOGRAPHY_NAME,OBS_VALUE")
raw_employment_rate_data <- content(empl_rate, as = "parsed", type = "text/csv", encoding = "UTF-8") %>%
  as_tibble()

names(raw_employment_rate_data) <- c("Year", "CPP", "Rate")

clean_employment_rate_data <- raw_employment_rate_data %>%
  filter(grepl("Apr", Year)) %>% #filters only the required Apr-Mar periods 
  dplyr::mutate(Year = str_replace_all(Year, "Apr ", "")) %>%
  dplyr::mutate(Year = str_replace_all(Year, "Mar " , "")) %>% #trims year data: 'Apr 2010 - Mar 2011' becomes 2010-2011
  dplyr::mutate(Year = gsub("-20", "-", Year))

rolled_average_employment_rates <- clean_employment_rate_data %>%
  dplyr::arrange(desc(CPP)) %>% 
  dplyr::group_by(CPP) %>% 
  dplyr::mutate("value" = zoo::rollmean(Rate, k = 3, fill = NA)) %>% 
  dplyr::mutate("value" = round(value,1)) %>%
  dplyr::ungroup() %>%
  select(!Rate) %>%
  na.omit()

scotland_totals <- rolled_average_employment_rates %>%
  group_by(Year) %>%
  summarise(value = mean(value)) %>%
  mutate(CPP = "Scotland")

final_employment_rates <- rbind(rolled_average_employment_rates, scotland_totals) %>%
  mutate(Indicator = "Employment Rate", Type = "Raw") %>%
  select(CPP, Year, Indicator, Type, value)

#writes final data to csv file in cloud directory for exporting
write.csv(final_employment_rates, file = "data_update/data/employment_rate_cpp.csv", row.names = FALSE)

