#sidebar-----------------------------------------
#creates three drop down selection components
sidebar <- dashboardSidebar(
  selectInput("LA1", 
              "Select CPP", 
              choices =  CPPNames),
  selectInput("CompLA1", 
              "Select Comparator", 
              c("Scotland",CPPNames),
              selected = "Scotland"),
  selectInput("indicator", 
              "Select indicator", 
              indicators,
              selected = "Attainment")
)

#body--------------------------------------------

body <- dashboardBody(
  fluidPage(
    fluidRow(
      column(12,
      plotlyOutput("overtimeplot")
      )
    )
  )
)

#create dashboard------------------------------------------------------

dashboardPage(title = "CPOP",
              dashboardHeader(title = "CPOP"),
              sidebar,
              body
              )