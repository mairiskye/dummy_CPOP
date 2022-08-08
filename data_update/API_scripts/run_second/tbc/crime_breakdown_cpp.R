crime_breakdown_query <- "PREFIX qb: <http://purl.org/linked-data/cube#>
select    ?Code ?CPP  ?Year ?Crime ?value 
where { ?data qb:dataSet <http://statistics.gov.scot/data/recorded-crime>. 
  ?data <http://purl.org/linked-data/sdmx/2009/dimension#refArea> ?refArea.
  ?refArea <http://www.w3.org/2004/02/skos/core#notation> ?Code.
  ?data <http://purl.org/linked-data/sdmx/2009/dimension#refPeriod> ?refPeriod.
  ?refPeriod <http://www.w3.org/2000/01/rdf-schema#label> ?Year.
  ?refArea <http://www.w3.org/2000/01/rdf-schema#label> ?CPP.
  ?data <http://purl.org/linked-data/cube#measureType> ?measureType.
  ?data <http://statistics.gov.scot/def/dimension/crimeOrOffence> ?crimeOrOffence.
  ?crimeOrOffence <http://www.w3.org/2000/01/rdf-schema#label> ?Crime.
  ?data ?measureType ?value. 
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
            regex(str(?refPeriod ), '2021-2022$'))  }"

crime_breakdown_resp <- httr::POST(
  url = "https://statistics.gov.scot/sparql.csv",
  body = list(query = crime_breakdown_query))

crime_breakdown_data <- content(crime_breakdown_resp, as = "parsed", encoding = "UTF-8") %>%
  filter(CPP == "Aberdeen City") %>%
  filter(Year == "2020/2021")

non_sexual_violence <- crime_breakdown_data %>%
  filter(grepl("Crimes: Group 1: ", Crime))
