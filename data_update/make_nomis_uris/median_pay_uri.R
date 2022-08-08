library(nomisr)

ashe_query <- httr::GET("https://www.nomisweb.co.uk/api/v01/dataset/def.sdmx.json?search=ASHE") %>%
  content(as = "parsed")

ashe_datasets <- ashe_query$structure$keyfamilies$keyfamily

ashe_metadata <- nomisr::nomis_get_metadata("NM_99_1")

ashe_time <- nomisr::nomis_get_metadata("NM_99_1", concept = "TIME")
#2008-2021

ashe_measures <- nomisr::nomis_get_metadata("NM_99_1", concept = "MEASURES")
#20100

ashe_geo_type <- nomisr::nomis_get_metadata("NM_99_1", concept = "GEOGRAPHY", "TYPE")
#432

ashe_geo_area <- nomisr::nomis_get_metadata("NM_99_1", concept = "GEOGRAPHY", type = "TYPE432") %>%
  filter(label.en == "Aberdeen City")
#2013265931

ashe_freq <- nomisr::nomis_get_metadata("NM_99_1", concept = "FREQ")

ashe_item <- nomisr::nomis_get_metadata("NM_99_1", concept = "ITEM")
#2

ashe_pay <- nomisr::nomis_get_metadata("NM_99_1", concept = "PAY")
#1

ashe_sex <- nomisr::nomis_get_metadata("NM_99_1", concept = "sex")
#7