#sidebar-----------------------------------------

sidebar <- dashboardSidebar(
  #selectizeInput("LA1",
  #               "",
  #               choices = CPPNames, 
  #               options = list(placeholder = "Select a CPP",
  #                              onInitialize = I('function() { this.setValue(""); }')
  #                              )
  #               ),
 sidebarMenu(id = "tabs",
              #menuItem("1. Community Map", tabName = "Map1", icon = icon("map")),
              menuItem("2. CPP Over Time", tabName = "P1", icon = icon("line-chart")),
              awesomeCheckbox("CBCols", "Colour Blind Colour Scheme", value = FALSE),
              tags$footer(a("Contact us", href = "mailto:benchmarking@improvementservice.org.uk"), style = "position:fixed; bottom:0; margin-left:2px")
              )
  )

#body--------------------------------------------

body <- dashboardBody(
  tags$head(tags$style(
    ".leaflet{height:36vh !important; border-style:solid; border-width:1px; margin-top:6px}",
    "#communityMap{height:91vh !important;border-style:solid;border-width:1px; margin-left:3px}",
    "#scotMap{height:91vh !important;border-style:solid;border-width:1px; margin-left:3px}",
    ".content{padding-top:1px}",
    ".col-sm-1{padding-left:2px; z-index:1}",
    ".col-sm-10{z-index:2}",
    ".content-wrapper, .right-side {
      background-color: #ffffff;
    }",
    "#comProgressBox{width:80%; padding-right:0px; padding-left:0px}",
    "#SimCPP{height:90vh !important}",
    "#CompCPP{height:75vh !important; margin-top:15px}",
    ".main-header .logo {text-align:left; padding-left:0px}",
    "#DLDta_bttn{margin-right:10px}",
    "#Map1P1{margin-left:20px}",
    "#P1P1{margin-left:20px}",
    "#MyComP1{margin-left:20px}",
    "#MyComP2{margin-left:20px}",
    "#CPP1{margin-left:20px}",
    "#CPP2{margin-left:20px}",
    ".popover{width:40vw; max-width:450px}",
    ".btn-group.bootstrap-select.form-control {background: border-box}",
    ".skin-blue {padding-right:0px}",
    "#VulnTable {margin-top:10px}",
    "#HeaderVuln {font-style:italic;
          font-family: sans-serif;
        font-size:3vh; margin-top:5px;
    }",
    HTML(" h5{height: 18px;
         margin-top:2px;
         margin-bottom:0px;
         text-align:centre;
         font-weight: bold;}
         h4 {font-size:12px;
         height: 18px;
         margin-top:2px;
         margin-bottom:0px;
         text-align:centre;
         font-weight: bold;}
        h3{font-style:italic;
          font-family: sans-serif;
        font-height:3vh}
      h2{font-family: sans-serif;
          font-weight:bold;
          font-size:5vh; 
          margin-top:6vh;
          text-decoration:underline}
        strong{float:right;}
          .small-box {margin-bottom:1px}
          .small-box >.inner {padding:5px}
         "))),
 

  tabItems(
    #tab 2: CPPs over Time ----------------------------------------------    
    tabItem(tabName = "P1",
            fluidPage(
              fluidRow(tags$div(style = "position: absolute; top: -100px;",
                                textOutput("clock")),
                       column(4,
                              div(style = "margin-top:5px;margin-bottom:20px",
                                  #tags$style("#LA1 {border: 2px solid #dd4b39;}"),
                                  selectInput("LA1", 
                                              "Select CPP", 
                                              choices =  CPPNames))),
                       column(4,
                              div(style = "margin-top:5px;margin-bottom:20px",
                                  selectInput("CompLA1", 
                                              "Select Comparator", 
                                              c("Scotland",CPPNames),
                                              selected = "Scotland"))),
                       column(4,
                              div(style = "margin-top:5px;margin-bottom:20px",
                                  selectInput("indicator", 
                                              "Select indicator", 
                                              indicators,
                                              selected = "Child Poverty")))),
              div(style = "margin-top:10px",
                  fluidRow(style = "margin-bottom:0px;margin-right:1px",
                          # plot_with_metadata_pop_up(Metadata, "over_time_plot", input$indicator, "bottom")
                          plotOutput("overtimeplot")
                           
                  )
                  
                  
              )  
    )
    )


)

)
#create dashboard------------------------------------------------------

dashboardPage(title = "CPOP",
              dashboardHeader(
                title = tags$img(src = "Improvement Service Logo.png", style = "height:110%;margin-left:3px"),
                tags$li(
                  class = "dropdown", 
                  tags$head(
                    tags$style(HTML('#HelpButton{background-color:White;
                                     font-size: 20px;
                                     font-weight: 600
                                    }')
                    )
                  ),
                  div(style = "padding-right:20px; padding-top:5px",actionBttn("HelpButton", "Help with this page", icon = icon("question-circle"), style = "jelly")))
              ),
              sidebar,
              body
)