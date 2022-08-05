library(shiny)  
library(readr)  
library(shinydashboard) 
library(dplyr)  
library(plotly)
library(ggplot2)
library(magrittr)

#MASTERDATA - update file name manually for data update.
CPPdta <- readr::read_csv("cpop_data/masterdata_05_08_22.csv")

Metadata <- readr::read_csv("cpop_data/Metadata.csv")

#global variables extracted from server script
indicators <- c("Healthy Birthweight", "Primary 1 Body Mass Index", "Child Poverty",
                  "Attainment", "Employment Rate",
                   "Out of Work Benefits")

#Create list of CPP names for use in UI drop down selection
CPPNames <- c("Aberdeen City","Aberdeenshire","Angus","Argyll and Bute",
              "Clackmannanshire","Dumfries and Galloway","Dundee City","East Ayrshire",
              "East Dunbartonshire","East Lothian","East Renfrewshire","Edinburgh, City of",
              "Eilean Siar", "Glasgow City","Highland","Inverclyde","Midlothian",
              "Moray","North Ayrshire","North Lanarkshire","Orkney Islands","Perth and Kinross",
              "Renfrewshire","Scottish Borders","Shetland Islands","South Ayrshire",
              "South Lanarkshire","Stirling","West Dunbartonshire","West Lothian")


