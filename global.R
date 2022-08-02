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

#Store value for the most recent year data is available, this needs to be changed when data is refreshed annually
FrstYear <- "2008/09"
RcntYear <- "2019/20"
ProjYear <- "2022/23"

#First and last years for Duncan Index graphs
DIFrYr <- substr(FrstYear,1,4)
DIRcYr <- substr(RcntYear,1,4)

LblFrst <- "08/09"
LblRcnt <- "19/20"
LblProj <- "22/23"

SpPolysDF <- read_rds("data/Shapes_decs.rds")
SpPolysIZ <- read_rds("data/IZshapes_decs.rds")
SpPolysLA <- read_rds("data/LAShps.rds")
CPPdta <- read_csv("data/CPPcleandata.csv")
CPP_Imp <- read_csv("data/Imp_rate_CPP.csv")
Metadata <- read_csv("data/Metadata.csv")

#rename Edinburgh
SpPolysIZ@data[SpPolysIZ@data$council == "Edinburgh","council"] <- "Edinburgh, City of" 
SpPolysDF@data[SpPolysDF@data$council == "Edinburgh","council"] <- "Edinburgh, City of" 

##create deciles for colours
CPPMapDta <- SpPolysDF@data
##convert to numeric
CPPMapDta[[15]] <- as.numeric(CPPMapDta[[15]])
CPPMapDta[[14]] <- as.numeric(CPPMapDta[[14]])


##read in Fife data for MyCommunity
#IGZ_latest_Fife <- read_csv("data/IGZ_latest_Fife.csv")
#IGZ_change_Fife <- read_csv("data/IGZ_change_Fife.csv")

#global variables extracted from server script
indicators <- c("Healthy Birthweight", "Primary 1 Body Mass Index", "Child Poverty",
                  "Attainment", "Employment Rate",
                   "Out of Work Benefits", "Fragility")
latest_CPP_Imp <- CPP_Imp %>% filter(Year == RcntYear)

#Create list of CPP names for use in UI
CPPNames <- unique(CPPMapDta[CPPMapDta$council != "Scotland", "council"])

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

trafficLightMarkerColour <- function (LA_dta, comparator_dta) {
  highIsPositive <- unique(LA_dta$`High is Positive?`)
  
  if_else(last(LA_dta$value) > last(comparator_dta$value), 
          if_else(last(LA_dta$Improvement_Rate) > last(comparator_dta$Improvement_Rate),
                  if_else(highIsPositive == "Yes",
                          "green",
                          "red"),
                  "yellow"),
          if_else(last(LA_dta$value) < last(comparator_dta$value),
                  if_else(last(LA_dta$Improvement_Rate) < last(comparator_dta$Improvement_Rate),
                          if_else(highIsPositive == "Yes",
                                  "red",
                                  "green"),
                          "yellow"),
                  "black")
  )
}

add_selected_indicators_tags <- function (dataset, var, input1, input2 = NULL) {
  var <- enquo(var)
  if(is.null(input2)) 
  {
    dta <- dataset %>% 
      mutate(userSelection = ifelse(!!var == input1, "A", "C"))
  }
  else
  {
    dta <- dataset %>% 
      mutate(userSelection = ifelse(!!var == input1, 
                                    "A",
                                    ifelse(!!var == input2, 
                                           "B", 
                                           "C")))
  }
  return(dta)
}
