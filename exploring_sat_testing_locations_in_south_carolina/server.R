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
})
