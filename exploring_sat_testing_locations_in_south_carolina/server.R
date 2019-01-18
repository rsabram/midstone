# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  output$sites <- renderPlot({
    
    averages_by_site_and_location %>% 
      filter(type %in% input$checkGroup) %>% 
      filter(outcome %in% input$selectVar) %>% 
      ggplot(
        aes(x = outcome, y = value, group=type, fill = type)
      ) +
      geom_bar(
        stat = "identity",
        position = position_dodge()
      )  +
      labs(x = element_blank(), y = 'Percentage', title = 'Demographic Groups')  +
      ylim(0, .70) +
      scale_x_discrete(labels=c("mean_pct_black" = "Black Students", 
                                "mean_pct_white" = "White Students",
                                "mean_pct_male" = "Male Students",
                                "mean_pct_frl" = "Free & Reduced Lunch",
                                "mean_pct_tested" = "Took the SAT")) +
      scale_fill_brewer(name = 'Subgroup', palette = "Paired") 
  })
  
  output$table <- renderTable(
    averages_by_site_and_location %>% 
      filter(type %in% input$checkGroup) %>% 
      filter(outcome %in% input$selectVar) %>% 
      arrange(type)
    )
  
  output$school_data <- renderDataTable(
    all_school_info,
    options = list(
      columnDefs = list(list(width = '30%', targets = list(0))),
      autoWidth=TRUE,
      scrollX=TRUE
    )
  )

  
  
  output$testing_average <- renderValueBox(valueBox(
    testing_site_t_tests %>% 
      filter(variable %in% input$ttestVar) %>% 
      select(mean_not_testing_sites),
     "Average for Non-Testing Sites", icon = icon("chalkboard"), color = "green"
  ))
  
  output$not_testing_average <- renderValueBox(valueBox(
    testing_site_t_tests %>% 
      filter(variable %in% input$ttestVar) %>% 
      select(mean_testing_sites), 
    "Average for Testing Sites", icon = icon("chalkboard-teacher"), color = "green"
  ))
  
  output$pvalue <- renderValueBox(valueBox(
    testing_site_t_tests %>% 
      filter(variable %in% input$ttestVar) %>% 
      select(p_value), 
    "P-Value", icon = icon("laptop"), color = "green"
  ))
  
  output$ttest <-renderValueBox({
    t <- testing_site_t_tests %>% 
      filter(variable %in% input$ttestVar) %>% 
      select(p_significance)
    
    if (t == 'Significant'){
    valueBox(testing_site_t_tests %>% 
               filter(variable %in% input$ttestVar) %>% 
               select(p_significance), 
             "T-Test Result", icon = icon("chart-line"), color = "green")
    }
    else {
    
    valueBox(testing_site_t_tests %>% 
      filter(variable %in% input$ttestVar) %>% 
      select(p_significance), 
    "T-Test Result", icon = icon("chart-line"), color = "red")
    }
  })
  
                                         
})
