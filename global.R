library(shiny)  #
library(readr)  #
library(shinydashboard) #
library(dplyr)  #
#library(plyr)
#library(tidyverse)
#library(readxl)
#library(shinythemes)
#library(RColorBrewer)
#library(DT)
#library(data.table)
#library(Unicode)
#library(leaflet)
#library(cowplot)
#library(shinyBS)
#library(shinycssloaders)
#library(shinyLP)
#library(kableExtra)
#library(shinyjs)
#library(shinyWidgets)
#library(formattable)
#library(stringr)
library(plotly) #

#CPPdta <- readr::read_csv("data_update/final_data/masterdata_03_08_22.csv")
CPPdta <- readr::read_csv("dashboard_data/masterdata_03_08_22.csv")
Metadata <- readr::read_csv("dashboard_data/Metadata.csv")

#global variables extracted from server script
indicators <- c("Healthy Birthweight", "Primary 1 Body Mass Index", "Child Poverty",
                  "Attainment", "Employment Rate",
                   "Out of Work Benefits")

#Create list of CPP names for use in UI drop down selection
CPPNames <- unique(CPPdta$CPP) %>%
  sort()
CPPNames[! CPPNames %in% "Scotland"]

