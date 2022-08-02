library(shiny)
library(shinydashboard)
library(plyr)
library(tidyverse)
library(readxl)
library(shinythemes)
library(RColorBrewer)
library(DT)
library(data.table)
library(Unicode)
library(leaflet)
library(cowplot)
library(shinyBS)
library(shinycssloaders)
library(shinyLP)
library(kableExtra)
library(shinyjs)
library(shinyWidgets)
library(formattable)
library(stringr)

CPPdta <- read_csv("newdata/masterdata.csv")
Metadata <- read_csv("data/Metadata.csv")

#global variables extracted from server script
indicators <- c("Healthy Birthweight", "Primary 1 Body Mass Index", "Child Poverty",
                  "Attainment", "Employment Rate",
                   "Out of Work Benefits")

#Create list of CPP names for use in UI
CPPNames <- unique(CPPdta$CPP)

plot_with_metadata_pop_up <- function (metadata, plotName, indicatorTitle, plc = "top", plotHeight = "25vh"){
  indicatorMetadata <- filter(metadata, Indicator == indicatorTitle)
  
  column(2, 
         style = paste0("margin-left:0px;margin-right:0px;padding-right:0px; padding-left:0px; height:", plotHeight,"!important"),
         plotOutput(plotName, height= plotHeight),
         bsPopover(id = plotName,
                   title = indicatorTitle, 
                   content = paste(
                     "<b>Definition</b></p><p>",
                     indicatorMetadata[[1,2]],
                     "</p><p>",
                     "<b>Raw Time Period</b></p><p>",
                     indicatorMetadata[[1,3]],
                     "</p><p>",
                     "<b>Source</b></p><p>",
                     indicatorMetadata[[1,4]]
                   ),
                   placement = plc,
                   trigger = "hover",
                   options = list(container = "body")
         )
  )
}


