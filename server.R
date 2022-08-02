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
  chart_data <- reactive({
    
    dta <- CPPdta %>% 
      filter(CPP %in% c(input$LA1, input$CompLA1)) %>%
      filter(Indicator %in% input$indicator) %>%
      select(CPP, Year, value)
  })
  


  # create plot
    local({
      output$overtimeplot <- renderPlotly({
        req(input$LA1)
        req(input$indicator)
        indicatorData <- chart_data()
        #FLAG: calculate min and max accross all CPPs so that graph doesn't shift
        #FLAG: make main CPP line bold
        #FLAG: increase font size
        # Y Axis Range for each plot, based on range of full data set
        min_value <- min(indicatorData$value, na.rm = TRUE)
        max_value <- max(indicatorData$value, na.rm = TRUE)
        padding <- (max_value - min_value) * 0.05
        y_min <- min_value - padding
        y_max <- max_value + padding
        
        # Create plot
        plot_ly(indicatorData, x = ~Year, y = ~value, type = 'scatter', mode = 'lines',  color = ~CPP) %>%
          layout(yaxis = list(range = c(y_min, y_max))) %>%
          config(displayModeBar = F) %>%
          layout(hovermode = 'x')
        
        })
    })
    
})
