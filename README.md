# midstone
Exploring SAT Testing Locations in South Carolina

Executive Summary
This section provides an overview to the project. It should briefly touch on the motivation, data question, data to be used, along with any known assumptions and challenges.

Through my time as an educator, I have developed a passion for expanding access to higher education for students from low income backgrounds. In my work in South Carolina I saw my students face obstacle after obstacle when it came to merely applying for college.  It wasn’t just a matter of funds - they didn’t have internet access at home to complete applications, or didn’t have a credit card to register for the SAT. In my midstone project, I want to explore a possible correlation between the locations of SAT testing sites and assorted demographic and social determinant factors. I anticipate that I will find that large, urban, wealthy counties will have the bulk of the testing sites. I will use various data sets from the South Carolina Department of Education, US Census, and College Board to explore this hypothesis. 

Motivation
Here you will go into more detail about why you have chosen this project.

From 2014-2016, I taught high school math and computer science in rural South Carolina (here). I taught primarily juniors and seniors, and as a wide-eyed Teach for America corps member I was determined to ensure 100% of my students could apply, attend, and graduate from college. I quickly realized this was not reality for my students - about 30% of the graduating class attended college after graduation and 30% of that population would go on to complete their degree. One particular barrier to higher education that concerned me was access to a testing location for the ACT or SAT. These tests are required for admittance to colleges and universities, and often a prerequisite for scholarships. The closest testing centers to my students were an hour away. I remember waking up at 5:30 a.m. on a Saturday to drive one of my students from his house to a testing center, and then to pick him up again after he finished to drive him home. I want to investigate the locations of SAT testing centers in South Carolina to identify possible trends and the impact of limited testing centers in rural locations. 

Data Question
Present your question. Include any research, including citations, where others have attempted to answer this question. Do you have an initial hypothesis?

Where are SAT testing centers in South Carolina? Are they in rural or urban locations? What are the demographic populations of the high schools designated as testing locations? What are the average SAT scores of students at schools that double as testing locations? Do counties with few testing locations have lower college graduation rates or lower high school graduation rates?

Based on my experience and prior knowledge, I would hypothesize that SAT testing centers are located in both counties and high schools with the following characteristics:
Urban 
High SAT scores
High high school graduation percentage
Large student population
Low non-white population
Low special education population
Low free and reduced lunch population
Low unemployment rate

Data Sources
What data will you use? Where will you get it?
SAT Testing Locations
SC Report Cards
SAT Scores by School
School Enrollment by Gender and Race
School FRL Rates
SC County Data

Known Issues and Challenges
Explain any anticipated challenges with your project, and your plan for managing them.
The SAT labels testing centers by their own 6-digit code called a CEEB (College Entrance Examination Board) from the Educational Testing Service. However, South Carolina consistently refers to their schools by a 7-digit state-assigned ID number. I’ll need to convert CEEB to State ID in order to merge data frames, and I’ll likely have to match these along a string match for the names of the high schools.
Exporting data from Census Website in format/with information I need in an understandable format.
