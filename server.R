shinyServer(function(input, output, session) {
  
  output$clock <- renderText({
    invalidateLater(5000)
    Sys.time()
  })
  
#CPP Over Time ------------------------------------------------------
  
  #update comparator CPP selection to exclude already selected CPP (from sidebar)
  observeEvent(input$LA1, {
    theseCPPNames <- CPPNames[CPPNames != input$LA1]
    updateSelectInput(session,"CompLA1", label = NULL, choices = c("Scotland",theseCPPNames))
  })
  
  #This reactive statement creates a column which 'tags' the selected local authority with the letter 'A'.
  #and all other LAs with a B which will be used to decide the line colour for the chart output
  tab_2_dta <- reactive({
    CPP_Imp_plus <- add_selected_indicators_tags(CPP_Imp, CPP, input$LA1, input$CompLA1) 
    dta <- filter(CPP_Imp_plus, CPP %in% c(input$LA1, input$CompLA1)) %>%
      filter(Indicator %in% input$indicator)
  })

  # create plot
    local({
      output$overtimeplot <- renderPlot({
        req(input$LA1)
        req(input$indicator)
        indicatorData <- tab_2_dta()
        #FLAG: calculate min and max accross all CPPs so that graph doesn't shift
        #FLAG: make main CPP line bold
        #FLAG: increase font size
        # Y Axis Range for each plot, based on range of full data set
        min_value <- min(indicatorData$value, na.rm = TRUE)
        max_value <- max(indicatorData$value, na.rm = TRUE)
        padding <- (max_value - min_value) * 0.05
        y_min <- min_value - padding
        y_max <- max_value + padding
        
        #EXPLANATION: subsetting data for specific indicator and
        #for the selected CPP and comparator CPP
        indicatorDataCPP1 <- filter(indicatorData, CPP == input$LA1)
        indicatorDataCPP2 <- filter(indicatorData, CPP == input$CompLA1)
        
        # set x axis labels on plots
        # need a column which stores a numeric series to be used as the break points
        # need an additional column which specifies the labels, allowing middle years to be blank
        # the numeric column is also used as a reactive reference point for setting the labels
        #FLAG: these columns could be added to the dataset in global.
        indicatorData <- arrange(indicatorData, CPP)
        indicatorData <- setDT(indicatorData)[, YearBreaks :=(seq(1 : length(Year))), by = CPP] %>%
          mutate(YearLbls = ifelse(YearBreaks == c(1,last(YearBreaks)), as.character(Year), ""))
        indicatorData$YearLbls <- indicatorData$YearLbls %>% str_sub(start = 3)
        year_breaks <- unique(indicatorData$YearBreaks)
        indicatorData$YearLbls[indicatorData$YearBreaks > 1 & indicatorData$YearBreaks < last(indicatorData$YearBreaks)] <- ""
        year_labels <- filter(indicatorData, CPP == input$LA1)$YearLbls
        
        # filter out imputed data for chart lines        
        recorded_data <- indicatorData %>% filter(Type == "Raw data")
        
        # Create plot
        ggplot()+
          geom_line(data = indicatorData,
                    aes(x = Year,
                        y = value,
                        group = userSelection,
                        colour = userSelection,
                        linetype = "2"),
                    lwd = 1, show.legend = FALSE) +
          geom_line(data = recorded_data,
                    aes(x = Year, 
                        y = value,
                        group = userSelection,
                        colour = userSelection,
                        linetype = "1"),
                    lwd = 1, 
                    show.legend = FALSE) +
          scale_color_manual(values = c("red", "gray")) +
          labs(title  = input$indicator) +
          annotate("text",
                   x = Inf,
                   y = Inf,
                   label = sprintf('\U25CF'),
                   size = 7,
                   colour = trafficLightMarkerColour(indicatorDataCPP1, indicatorDataCPP2),
                   hjust = 1,
                   vjust = 1) +
          #scale_x_continuous(breaks = Year,
           #                  labels = year_labels) +
          ylim(y_min, y_max) #+
          #theme(plot.title = element_text(size = 30),
               # panel.grid.major = element_blank(),
                #panel.grid.minor = element_blank(), 
                #panel.background = element_blank(),
               # axis.line = element_line(colour="black"),
               # axis.text.x = element_text(vjust = 0.3),
                #axis.text.y = element_text(size = 7),
               # axis.title.x = element_blank(),
               # axis.title.y = element_blank()
               # )
        })
    })
    
})
