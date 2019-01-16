dashboardPage(
  skin = 'green',
  dashboardHeader(
    title = "SAT Testing Sites in Rural SC",
    titleWidth = 300),
  dashboardSidebar(
    width = 300,
    sidebarMenu(
      menuItem("Overview", tabName = "overview", icon = icon("chalkboard-teacher")),
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
                                       selected = "Rural, No Testing Sites"),
                    selectInput("selectVar",
                                label = "Variables",
                                choices = variables,
                                multiple = TRUE,
                                selected = unlist(head(variables, n = 5))),
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
      tabItem(tabName = "t_tests"),
      tabItem(tabName = "contact")
    )
  )
)
