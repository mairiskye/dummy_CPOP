library(magrittr)
library(dplyr)
library(httr)

median_pay_uri <- "https://www.nomisweb.co.uk/api/v01/dataset/NM_99_1.data.csv?geography=2013265931TYPE432&measures=20100&item=2&pay=1&sex=7&time=2008,latest&select=DATE,GEOGRAPHY_NAME,OBS_VALUE"

median_pay_response <- httr::GET(median_pay_uri)
median_pay_data <- content(median_pay_response, as = "parsed", type = "text/csv", encoding = "UTF-8") %>%
  as_tibble()

names(median_pay_data) <- c("Year", "CPP", "value")

scotland_totals <- median_pay_data %>%
  group_by(Year) %>%
  summarise(value = mean(value, na.rm = TRUE)) %>%
  mutate(CPP = "Scotland")

final_median_pay_data <- rbind(median_pay_data, scotland_totals) %>%
  mutate(Indicator = "Median Pay",
         Type = "Raw") %>%
  select(CPP, Year, Indicator, Type, value) %>%
  arrange(CPP, Year)

write.csv(final_median_pay_data, "data_update/data/median_pay_cpp.csv", row.names = FALSE)
