library(httr)
library(dplyr)
library(magrittr)

crime_query <- httr::POST(
  url = "https://statistics.gov.scot/sparql.csv",
  body = list(query = "PREFIX qb: <http://purl.org/linked-data/cube#>
select    ?Code ?CPP ?Year ?value 
where { ?data qb:dataSet <http://statistics.gov.scot/data/recorded-crime>. 
  ?data <http://purl.org/linked-data/sdmx/2009/dimension#refArea> ?refArea.
  ?refArea <http://www.w3.org/2004/02/skos/core#notation> ?Code.
  ?data <http://purl.org/linked-data/sdmx/2009/dimension#refPeriod> ?refPeriod.
  ?refPeriod <http://www.w3.org/2000/01/rdf-schema#label> ?Year.
  ?refArea <http://www.w3.org/2000/01/rdf-schema#label> ?CPP.
  ?data <http://purl.org/linked-data/cube#measureType> ?measureType. 
  ?data <http://statistics.gov.scot/def/dimension/crimeOrOffence> ?crimeOrOffence. 
  ?data ?measureType ?value. 
  filter (regex(str(?crimeOrOffence ), 'all-crimes$')) 
  filter (regex(str(?measureType ), 'count$')) 
  filter (regex(str(?refPeriod ), '2008-2009$')||
    regex(str(?refPeriod ), '2009-2010$')||
    regex(str(?refPeriod ), '2010-2011$')||
    regex(str(?refPeriod ), '2011-2012$')||
    regex(str(?refPeriod ), '2012-2013$')||
    regex(str(?refPeriod ), '2013-2014$')||
    regex(str(?refPeriod ), '2014-2015$')||
    regex(str(?refPeriod ), '2015-2016$')||
    regex(str(?refPeriod ), '2016-2017$')||
    regex(str(?refPeriod ), '2017-2018$')||
    regex(str(?refPeriod ), '2018-2019$')||
    regex(str(?refPeriod ), '2019-2020$')||
    regex(str(?refPeriod ), '2020-2021$')||
    regex(str(?refPeriod ), '2021-2022$'))  }"))

#parse response
crime_data <- content(crime_query, as = "parsed", encoding = "UTF-8") %>%
  select(!Code)

final_crime_data <- crime_data %>%
  mutate(Indicator = "Crime",
         Type = "Raw") %>%
  select(CPP, Year, Indicator, Type, value) %>%
  arrange(CPP, Year)

write.csv(final_crime_data, "data_update/data/crime_cpp.csv", row.names = FALSE)

