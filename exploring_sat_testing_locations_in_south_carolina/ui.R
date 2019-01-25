dashboardPage(
  skin = 'green',
  dashboardHeader(
    title = "SAT Testing Sites in Rural SC",
    titleWidth = 300),
  dashboardSidebar(
    width = 300,
    sidebarMenu(
      menuItem('Overview',tabName = "overview",icon = icon('bookmark')),
      menuItem("School Data", tabName = "schools", icon = icon('database')),
      menuItem("Comparing Rural vs. Urban Testing Sites", tabName = "rural_v_urban", icon = icon("school")),
      menuItem("Statistical Significance", tabName = "t_tests", icon = icon("chart-line")),
      menuItem("Contact Me", tabName = "contact", icon = icon('envelope'))
    )),
  dashboardBody(
    tabItems(
      tabItem(tabName = "overview",
              fluidPage(
                sidebarLayout(
                  sidebarPanel(h1('Exploring SAT Testing Sites in South Carolina'),
                               h3(strong('Project Summmary & Motivation')),
                               h4('From 2014-2016, I taught high school math and computer science in rural South Carolina',here <- a("(here).", href="https://www.marion.k12.sc.us/Domain/12", target="_blank") , "I taught primarily juniors and seniors, and as a wide-eyed Teach for America corps member I was determined to ensure 100% of my students could apply, attend, and graduate from college. I quickly realized this was not reality for my students - about 30% of the graduating class attended college after graduation and 30% of that population would go on to complete their degree. One particular barrier to higher education that concerned me was access to a testing location for the ACT or SAT. These tests are required for admittance to colleges and universities, and often a prerequisite for scholarships. The closest testing centers to my students were an hour away. I remember waking up at 5:30 a.m. on a Saturday to drive one of my students from his house to a testing center, and then to pick him up again after he finished to drive him home. Here, I explore a possible correlation between the locations of SAT testing sites and assorted demographic and social determinant factors."),
                               h3(strong('Key Data Questions')),
                               h4('Is there a difference in demographic groups for high schools that are:'),
                               h4(tags$ul(tags$li("Rural vs. Urban"),tags$li("Testing Sites vs. Non Testing Sites"))),
                               h4('Is there a statistically significant difference in demographic groups, school quality, or SAT scores for high schools that are testing sites vs. those that are not?
                                  '),
                               h3(strong('Data Sources')),
                               h5(em('*all data is from 2018')),
                               h4(tags$ul(
                                 tags$li(locations <- a("SAT Testing Locations", href="https://collegereadiness.collegeboard.org/pdf/sat-domestic-code-list.pdf", target="_blank")),
                                 tags$li(report_card <- a("SC Report Cards", href="https://screportcards.com/", target="_blank")),
                                 tags$li(sat_scores <- a("SAT Scores by School", href="https://ed.sc.gov/data/test-scores/national-assessments/sat/", target="_blank")),
                                 tags$li(enrollment <- a("School Enrollment by Gender and Race", href="https://ed.sc.gov/data/other/student-counts/active-student-headcounts/", target="_blank")),
                                 tags$li(frl_rate <- a("School Poverty Index", href="https://screportcards.com/", target="_blank"))
                                 )
                                 ),
                               width = 12),
                  mainPanel()
                )
              )
            ),
      tabItem(tabName = "rural_v_urban",
              title = "title",
              status = "primary", solidHeader = TRUE, width=3,
              fluidPage(
                sidebarLayout(
                  # Add a sidebar panel around the text and inputs
                  fluidRow(
                    sidebarPanel(
                      h2('Explore Trends for Urban/Rural School Sites'),
                      h4('Select the population groups and variables you want to explore to visualize differences in the bar graph below.'),
                    checkboxGroupInput("checkGroup", label = strong("School Groups"), 
                                       choices = list("Rural, Not Testing Site"= "Rural, No Testing Sites", "Rural, Testing Site" = 'Rural, Testing Sites', "Urban, Not Testing Site" = "Urban, No Testing Sites", "Urban, Testing Site" = "Urban, Testing Sites"),
                                       selected = list("Rural, No Testing Sites","Urban, Testing Sites")),
                    selectInput("selectVar",
                                label = "Variables",
                                choices = list("Percentage of Students Receiving Free or Reduced Lunch" = "mean_pct_frl","Percentage of Seniors who Took SAT" = "mean_pct_tested", "Black Student Percentage" = "mean_pct_black", "White Student Percentage" = "mean_pct_white", "Male Student Percentage" = "mean_pct_male"),
                                multiple = TRUE,
                                selected = list("mean_pct_frl","mean_pct_tested")),
                  width = 10)
                  ),
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
                sidebarLayout(
                  sidebarPanel(
                    fluidRow(h4('Run a t-test to determine if there is a statistically significant difference in demographic groups, school quality, or SAT scores for high schools that are testing sites vs. those that are not.'),
                  selectInput("ttestVar", label = ("Select a variable:"), 
                            choices = list("Total SAT Score" = "total_score", "Reading SAT Score" = "erw_score", "Math SAT Score" = "math_score", "Total Enrollment" = "total_enrollment", "Male Student Percentage" = "pct_male", "Black Student Percentage" = "pct_black", "White Student Percentage" = "pct_white", "Percentage of Students Receiving Free or Reduced Lunch" = "pct_frl", "Percentage of Seniors who Took the SAT" = "pct_tested", "Overall School Rating" = "overall_rating", "School Achievement Rating" = "achievement_rating", "School Graduation Rate Rating" = "gradrate_rating"), 
                            selected = 1), color = "green", width = 8
              ),
                  fluidRow(strong('Wait - what is a t-test?')),
                 fluidRow("Here, a t-test compares the means of a specific variable across two different populations - schools that are testing sites vs. schools that are not. It evaluates the two averages, and calculates a p-value for the comparison. A higher p-value means there is not a large difference between the means of the two groups, and a lower p-value means there is a significant difference between the means of the two groups. A p value lower than 0.05 is considered significant. Learn more about t-tests", link <- a('here.', href = 'https://www.khanacademy.org/math/ap-statistics/two-sample-inference/two-sample-t-test-means/v/two-sample-t-test-for-difference-of-means', target="_blank"))
              ),
              mainPanel(
              fluidRow(valueBoxOutput("testing_average", width = 8)),
              fluidRow(valueBoxOutput("not_testing_average", width = 8)),
              fluidRow(valueBoxOutput("pvalue", width = 8)),
              fluidRow(valueBoxOutput("ttest", width = 8))
              )))),
              
      tabItem(tabName = "schools",
              fluidPage(
                sidebarLayout(
                  fluidRow(
                    sidebarPanel(h4('Review or download all South Carolina high school data below.'), downloadButton("downloadData", "Download"),
                                 width = 12)
                  ),
                  fluidRow(
                    mainPanel(dataTableOutput("school_data"),width = 12)
                  )
                )
              )
            
      ),
      tabItem(tabName = "contact",
              fluidPage(
                sidebarLayout(
                  sidebarPanel(
                    h3('Rachael Abram'),
                    h4(email <- a("Email", href="mailto:rachaelshore@gmail.com?Subject=SAT%20Testing%20Site%20Analysis%20App", target="_blank")),
                    h4(linkedin <- a("LinkedIn", href="https://www.linkedin.com/in/rsabram/", target="_blank")),
                    h4(github <- a("GitHub", href="https://github.com/rsabram", target="_blank")), width = 6
                  ),
                  mainPanel()
                )
              )
      )
  )
)
)



