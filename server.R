shinyServer(function(input, output, session) {
  
  output$clock <- renderText({
    invalidateLater(5000)
    Sys.time()
  })
  
  #update comparator CPP selection options to exclude the primary selected CPP
  observeEvent(input$LA1, {
    theseCPPNames <- CPPNames[CPPNames != input$LA1]
    updateSelectInput(session,"CompLA1", label = NULL, choices = c("Scotland",theseCPPNames))
  })
  
  #this expression filters the main datasets by the three user inputs and 
  # will update reactively to any change to any input
  chart_data <- reactive({
    dta <- CPPdta %>% 
      dplyr::filter(CPP %in% c(input$LA1, input$CompLA1)) %>%
      dplyr::filter(Indicator %in% input$indicator) %>%
      dplyr::select(CPP, Year, value)
  })
  
#determines y axis upper and lower limits using all CPP data for the selected indicator
  #   creates a two element vector (min, max)
  indicator_limits <- reactive({
    indicator_data <- CPPdta %>% filter(Indicator %in% input$indicator)
    min_value <- min(indicator_data$value, na.rm = TRUE)
    max_value <- max(indicator_data$value, na.rm = TRUE)
    padding <- (max_value - min_value) * 0.15
    y_min <- min_value - padding
    y_max <- max_value + padding
    limits <- c(y_min, y_max)
    return(limits)
  })

  # create plot
    local({
      output$overtimeplot <- renderPlotly({
        
        #store reactive expression data for use as plot arguments
        filtered_data <- chart_data()
        y_limits <- indicator_limits()
        
        # Create line graph for two selected CPPs over time with hover interactivity
        plot_ly(filtered_data, x = ~Year, y = ~value, type = 'scatter', mode = 'lines',  color = ~CPP) %>%
          layout(title = input$indicator,
                 yaxis = list(range = c(y_limits[1], y_limits[2]))) %>%
          config(displayModeBar = F) %>%
          layout(hovermode = 'x')
        
        })
    })
    
})
