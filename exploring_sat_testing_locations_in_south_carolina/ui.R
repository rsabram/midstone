dashboardPage(
  skin = 'green',
  dashboardHeader(
    title = "SAT Testing Sites in Rural SC",
    titleWidth = 300),
  dashboardSidebar(
    width = 300,
    sidebarMenu(
      menuItem("Overview", tabName = "overview", icon = icon("chalkboard-teacher")),
      menuItem("School Data", tabName = "schools", icon = icon('database')),
      menuItem("Comparing Rural vs. Urban Testing Sites", tabName = "rural_v_urban", icon = icon("school")),
      menuItem("Statistical Significance", tabName = "t_tests", icon = icon("chart-line")),
      menuItem("Contact", tabName = "contact", icon = icon('envelope'))
    )),
  dashboardBody(
    tabItems(
      tabItem(tabName = "overview"),
      tabItem(tabName = "rural_v_urban",
              title = "title",
              status = "primary", solidHeader = TRUE, width=3,
              fluidPage(
                sidebarLayout(
                  # Add a sidebar panel around the text and inputs
                  fluidRow(
                  sidebarPanel(
                    checkboxGroupInput("checkGroup", label = h3("School Groups"), 
                                       choices = list("Rural, Not Testing Site"= "Rural, No Testing Sites", "Rural, Testing Site" = 'Rural, Testing Sites', "Urban, Not Testing Site" = "Urban, No Testing Sites", "Urban, Testing Site" = "Urban, Testing Sites"),
                                       selected = list("Rural, No Testing Sites","Urban, Testing Sites")),
                    selectInput("selectVar",
                                label = "Variables",
                                choices = list("Percentage of Students Receiving Free or Reduced Lunch" = "mean_pct_frl","Percentage of Seniors who Took SAT" = "mean_pct_tested", "Black Student Percentage" = "mean_pct_black", "White Student Percentage" = "mean_pct_white", "Male Student Percentage" = "mean_pct_male"),
                                multiple = TRUE,
                                selected = list("mean_pct_frl","mean_pct_tested")),
                  width = 5)),
                  # Add a main panel around the plot and table
                  fluidRow(mainPanel( 
                    tabsetPanel(
                      tabPanel("Plot", plotOutput("sites",height = 500, width = 950)), 
                      tabPanel("Table", tableOutput("table"))
                    )
                  )
                ))
                )
              ),
      tabItem(tabName = "t_tests",
              fluidPage(
                fluidRow(selectInput("select", label = h3("Select a variable:"), 
                            choices = list("Total SAT Score" = "total_mean", "Reading SAT Score" = "erw_mean", "Math SAT Score" = "math_mean", "Total Enrollment" = "total_enrollment", "Male Student Percentage" = "pct_male", "Black Student Percentage" = "pct_black", "White Student Percentage" = "pct_white", "Percentage of Students Receiving Free or Reduced Lunch" = "pct_frl", "Percentage of Seniors who Took the SAT" = "pct_tested", "Overall School Rating" = "overall_rating", "School Achievement Rating" = "achievement_rating", "School Graduation Rate Rating" = "gradrate_rating"), 
                            selected = 1)
              ),
              fluidRow(column(4,actionButton("action", label = "Run T-Test")
              )),
              fluidRow(column(8,print(h2("Variable:")))),
              fluidRow(column(8,print(h2("Average for Non-Testing Sites:")))),
              fluidRow(column(8,print(h2("Average for Testing Sites:")))),
              fluidRow(column(8,print(h2("P-Value:"))))
              )),
      tabItem(tabName = "schools",
              fluidRow(dataTableOutput("school_data"))
      ),
      tabItem(tabName = "contact")
    )
  )
)
