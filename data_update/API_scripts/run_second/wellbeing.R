library(magrittr)
library(dplyr)
library(tidyr)
library(onsr)

data <- onsr::ons_get(id = "wellbeing-local-authority", edition = "time-series", version = 2, ons_read = getOption("onsr.read"))

geographies <- data$`administrative-geography`[grepl("s", data$`administrative-geography`, ignore.case = TRUE)] %>% unique()

extract <- data %>% filter(`administrative-geography`%in% geographies) %>%
  filter(Estimate == "Average (mean)") %>%
  select(Geography, Time,MeasureOfWellbeing, V4_3)

#anxiety values altered: (anxiety figure = 10 - anxiety figure)
extract[extract$MeasureOfWellbeing == "Anxiety",]$V4_3 <- 10 - extract[extract$MeasureOfWellbeing == "Anxiety",]$V4_3

#average all wellbeing measures 
wellbeing_aggregate <- extract %>%
  group_by(Geography, Time) %>%
  summarise("wellbeing_score" = mean(V4_3))

names(wellbeing_aggregate) <- c("CPP", "Year", "value")

final_wellbeing_data <- wellbeing_aggregate %>%
  mutate(Indicator = "Wellbeing",
         Type = "Raw") %>%
  select(CPP, Year, Indicator, Type, value) %>%
  arrange(CPP, Year)

write.csv(final_wellbeing_data, "data_update/data/wellbeing_cpp.csv", row.names = FALSE)
