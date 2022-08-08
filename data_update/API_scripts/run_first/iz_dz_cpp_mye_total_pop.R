library(opendatascot)
library(magrittr)
library(dplyr)

all_datasets <- opendatascot::ods_all_datasets()
dataset_uri <- "population-estimates-2011-datazone-linked-dataset"
structure <- opendatascot::ods_structure(dataset_uri)

years <- structure$categories$refPeriod

years <- c("2008", "2009", "2010", "2011" ,"2012" ,"2013" , "2014" ,"2015" ,"2016", "2017", "2018", "2019",
            "2020")

cpp_populations <- opendatascot::ods_dataset("population-estimates-2011-datazone-linked-dataset",
                                       geography = "la",
                                       sex = "all")

iz_total_population <- opendatascot::ods_dataset("population-estimates-2011-datazone-linked-dataset",
                                             geography = "iz",
                                             sex = "all") %>%
  select(refArea,refPeriod, value)

dz_total_population_17_21 <- opendatascot::ods_dataset("population-estimates-2011-datazone-linked-dataset",
                                                 refPeriod = c("2017" ,"2018" ,"2019", "2020" ,"2021"),
                                                 geography = "dz",
                                                 sex = "all")

dz_total_population_12_16 <- opendatascot::ods_dataset("population-estimates-2011-datazone-linked-dataset",
                                                       refPeriod = c("2012", "2013", "2014" ,"2015", "2016"),
                                                       geography = "dz",
                                                       sex = "all")

dz_total_population_08_11 <- opendatascot::ods_dataset("population-estimates-2011-datazone-linked-dataset",
                                                       refPeriod = c("2008", "2009", "2010" ,"2011"),
                                                       geography = "dz",
                                                       sex = "all")

dz_total_population <- rbind(dz_total_population_17_21, dz_total_population_12_16, dz_total_population_08_11) %>%
  select(refArea, refPeriod, value)

write.csv(dz_total_population, "data/denom data/dz_populations.csv")
write.csv(iz_total_population, "data/denom data/iz_populations.csv")
write.csv(cpp_populations, "data/denom data/cpp_populations_wa_child_old_all.csv")
