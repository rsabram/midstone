setwd('/Users/rabram/Desktop/NSS/sat_testing_locations_in_south_carolina')
library(tidyverse)
library(ggplot2)
library(fuzzyjoin)

# read in and clean adm data
adm <- read_csv('./data/sc_adm_18-19.csv')
adm <- adm[-c(1, 2, 3, 4, 5, 1229, 1230), ]
colnames(adm) <- adm[1,]
adm <- adm[-1,]
colnames(adm) <- c('SID','district','school','total','female','male','missing1','black', 'ai', 'aa','hispanic','hawaiian','two_or_more','white','missing2')
adm_clean <- adm %>% 
  select(-missing1, -missing2)

# remove commas in numbers
adm_clean$total <- mapply(gsub, pattern = ",", replacement = '', adm_clean$total)
adm_clean$male <- mapply(gsub, pattern = ",", replacement = '', adm_clean$male)
adm_clean$female <- mapply(gsub, pattern = ",", replacement = '', adm_clean$female)
adm_clean$black <- mapply(gsub, pattern = ",", replacement = '', adm_clean$black)
adm_clean$white <- mapply(gsub, pattern = ",", replacement = '', adm_clean$white)

# convert to numeric, add columns for race percentages
adm_clean <- adm_clean %>% 
  mutate_at(vars(-district, -school),as.numeric) %>% 
  mutate(pct_black = black/total) %>% 
  mutate(pct_white = white/total)

# import frl data
frl <- read_csv('./data/frl_data_2014.csv') %>% 
  select(District, School, SchoolId, Total, 'Grand FRL Total', Location)

# change column names
colnames(frl) <- c('district', 'school','SID','total_enrollment','frl_enrollment','location_type')

# drop first two rows of nonsense
frl <- frl[-c(1, 2), ]

#convert columns to numeric
frl$total_enrollment <- as.numeric(frl$total_enrollment)
frl$frl_enrollment <- as.numeric(frl$frl_enrollment)
frl$SID <- as.numeric(frl$SID)

# add column for pct frl
frl_clean <- frl %>% 
  mutate(pct_frl = frl_enrollment/total_enrollment)

# read in and clean test sites
test_sites <- read_csv('./data/sat_locations.csv') %>% 
  drop_na()

# read in and clean report cards
report_cards <- read_csv('./data/sc_report_card_data_2018.csv')
report_cards <- report_cards[-c(1), ]
colnames(report_cards) <- report_cards[1,]
report_cards <- report_cards[-1,]
report_cards_clean <- report_cards %>% 
  select(SchoolNm, SCHOOLID, SCHOOLTYPECD, RATE_OVERALL, RATE_ACHIEVE, RATE_GRADRATE) %>% 
  filter(SCHOOLTYPECD == 'H')
colnames(report_cards_clean) <- c('school', 'SID', 'grade_levels', 'rate_overall', 'rate_acheivement', 'rate_gradrate')
report_cards_clean$SID <- as.numeric(report_cards_clean$SID)

# read in and clean sat score data
sat_scores <- read_csv('./data/sat_scores_2018.csv')
sat_scores <- sat_scores[-c(1, 2, 3, 5, 6), ]
colnames(sat_scores) <- sat_scores[1,]
sat_scores <- sat_scores[-1,]
colnames(sat_scores) <- c('SID', 'school', 'district', 'no_testers', 'no_seniors', 'pct_tested', 'erw_mean', 'math_mean', 'total_mean')
sat_scores %>% 
  select(-pct_tested)
sat_scores_clean <- sat_scores %>% 
  mutate_at(vars(-district, -school),as.numeric) %>% 
  mutate(pct_tested = no_testers/no_seniors)

# MERGE IT ALL TOGETHER 
merge_1 <- left_join(report_cards_clean, sat_scores_clean, by = 'SID') %>% 
  select(-school.y, -grade_levels)
merge_2 <- left_join(merge_1, adm_clean, by = 'SID') %>% 
 select(-district.y, -school)
school_info <- left_join(merge_2, frl_clean, by = 'SID')

# clean the merge
school_info <- school_info %>% 
  select(-district, -school, -no_seniors, -black, -ai, -white, -aa, -hispanic, -hawaiian, -two_or_more, -total_enrollment, -frl_enrollment, -female) %>% 
  mutate(pct_male = male/total) %>% 
  select(-male)

colnames(school_info) <- c('school','SID','rate_overall','rate_achievement','rate_gradrate', 'district','no_seniors_tested','pct_tested','erw_mean','math_mean','total_mean','total_enrollment','pct_black','pct_white', 'location_type','pct_frl','pct_male')
school_info <- school_info %>% 
  select(SID, school, district, location_type, total_enrollment, pct_male, pct_black, pct_white, pct_frl, rate_overall, rate_achievement, rate_gradrate, no_seniors_tested, pct_tested, erw_mean, math_mean, total_mean)

school_info$district[156] <- 'Marion 10'

# merge school testing sites with school info (?)
sid <- school_info %>% 
  select(SID, school, district)

# clean test sites df to match formatting for school info
colnames(test_sites) <- c('number_times_offered','ceeb','school')
test_sites$school <- mapply(gsub, pattern = "HS", replacement = 'High School', test_sites$school)
test_sites$school <- mapply(gsub, pattern = "Sr", replacement = 'Senior', test_sites$school)
test_sites$school <- mapply(gsub, pattern = "Comp", replacement = 'Comprehensive', test_sites$school)
test_sites$school <- mapply(gsub, pattern = "Vly", replacement = 'Valley', test_sites$school)

# fuzzy join from ceeb to SID
ceeb_to_sid <- stringdist_left_join(test_sites, sid, by = 'school', max_dist = 1)

# manual add for missing values / fuzzy match didn't work
ceeb_to_sid$SID[3] <- 201002
ceeb_to_sid$SID[4] <- 405038
ceeb_to_sid$SID[9] <- 3901003
ceeb_to_sid$SID[15] <- 4001007
ceeb_to_sid$SID[26] <- 1101003
ceeb_to_sid$SID[27] <- 1001022
ceeb_to_sid$SID[32] <- 3410024
ceeb_to_sid$SID[45] <- 201012

testing_sites_clean <- ceeb_to_sid %>% 
  select(number_times_offered, SID) %>% 
  mutate(testing_site = 1) %>% 
  drop_na()

# NOTE - of the 68 testing sites, 6 are colleges and 4 are private schools

# merge testing site information with school info df
all_school_info <- left_join(school_info, testing_sites_clean, by = 'SID')

# replace NA with 0 for testing information
all_school_info$number_times_offered[is.na(all_school_info$number_times_offered)] <- 0
all_school_info$testing_site[is.na(all_school_info$testing_site)] <- 0
all_school_info$no_seniors_tested[is.na(all_school_info$no_seniors_tested)] <- 0
all_school_info$pct_tested[is.na(all_school_info$pct_tested)] <- 0

# fix cell that calculated to Inf
all_school_info[242,14] <- NA

# CBHS is a testing site but has no students who have taken the SAT - code below adds that in 
all_school_info[156,14] <- 0
all_school_info[156,13] <- 0

## START ANALYSIS HERE ->

# Convert ratings to numeric values

all_school_info <- all_school_info %>% 
  mutate(
    overall_rating = case_when(
      rate_overall == 'Unsatisfactory' ~ 1,
      rate_overall == 'Below Average' ~ 2,
      rate_overall == 'Average' ~ 3,
      rate_overall == 'Good' ~ 4,
      rate_overall == 'Excellent' ~ 5
    )
  ) %>% 
  mutate(
    achievement_rating = case_when(
      rate_achievement == 'Unsatisfactory' ~ 1,
      rate_achievement == 'Below Average' ~ 2,
      rate_achievement == 'Average' ~ 3,
      rate_achievement == 'Good' ~ 4,
      rate_achievement == 'Excellent' ~ 5
    )
  ) %>% 
  mutate(
    gradrate_rating = case_when(
      rate_gradrate == 'Unsatisfactory' ~ 1,
      rate_gradrate == 'Below Average' ~ 2,
      rate_gradrate == 'Average' ~ 3,
      rate_gradrate == 'Good' ~ 4,
      rate_gradrate == 'Excellent' ~ 5
    )
  )

# add row that averages each column
#all_school_info <- all_school_info %>%
#  bind_rows(summarise_all(., funs(if(is.numeric(.)) mean(., na.rm = TRUE) else "Average")))

table(all_school_info$location_type)
table(all_school_info$rate_overall)

rural_sites <- all_school_info %>% 
  group_by(location_type) %>% 
  mutate(location_type_testing_site_count = sum(testing_site, na.rm = TRUE)) %>% 
  select(location_type, location_type_testing_site_count) %>% 
  unique()

distict_sites <- all_school_info %>% 
  group_by(district) %>% 
  mutate(district_testing_site_count = sum(testing_site, na.rm = TRUE)) %>% 
  select(district, district_testing_site_count) %>% 
  unique()

rating_sites <- all_school_info %>% 
  group_by(rate_overall) %>% 
  mutate(rate_site_count = sum(testing_site, na.rm = TRUE)) %>% 
  select(rate_overall, rate_site_count) %>% 
  unique()

gradrate_sites <- all_school_info %>% 
  group_by(rate_gradrate) %>% 
  mutate(gradrate_site_count = sum(testing_site, na.rm = TRUE)) %>% 
  select(rate_gradrate, gradrate_site_count) %>% 
  unique()

all_school_info %>% 
  group_by(testing_site) %>% 
  summarize(mean(pct_tested, na.rm = TRUE))

averages_by_location <- all_school_info %>% 
  group_by(location_type) %>% 
  summarize(
    mean(pct_frl, na.rm = TRUE), 
    mean(pct_black, na.rm = TRUE),
    mean(pct_white, na.rm = TRUE),
    mean(pct_male, na.rm = TRUE),
    mean(pct_tested, na.rm = TRUE),
    mean(erw_mean, na.rm = TRUE),
    mean(math_mean, na.rm = TRUE),
    mean(total_mean, na.rm = TRUE),
    mean(number_times_offered, na.rm = TRUE)
  ) 

averages_by_location <- averages_by_location[-c(2,4),]
colnames(averages_by_location) <- c('location_type', 'mean_pct_frl', 'mean_pct_black','mean_pct_white','mean_pct_male','mean_pct_tested', 'mean_erw_score','mean_math_score', 'mean_score', 'mean_times_offered')

## Rural Unknown   Urban 
## 118       7     106 

## w E i R d anomaly - CBHS offers testing 6 times a year according to the SAT but 0 kids from CBHS have taken the SAT! 

averages_by_testing_site <- all_school_info %>% 
  group_by(testing_site) %>% 
  summarize(
    mean(pct_frl, na.rm = TRUE), 
    mean(pct_black, na.rm = TRUE),
    mean(pct_white, na.rm = TRUE),
    mean(pct_male, na.rm = TRUE),
    mean(pct_tested, na.rm = TRUE),
    mean(erw_mean, na.rm = TRUE),
    mean(math_mean, na.rm = TRUE),
    mean(total_mean, na.rm = TRUE),
    mean(total_, na.rm = TRUE),
    mean(overall_rating, na.rm = TRUE),
    mean(achievement_rating, na.rm = TRUE),
    mean(gradrate_rating, na.rm =TRUE)
  ) 

colnames(averages_by_testing_site) <- c('testing_site_boolean', 'mean_pct_frl', 'mean_pct_black','mean_pct_white','mean_pct_male','mean_pct_tested', 'mean_erw_score','mean_math_score', 'mean_score', 'mean_times_offered',"mean_overall_rating","mean_achievement_rating","mean_gradrate_rating")

averages_by_site_and_location <- all_school_info %>% 
  group_by(location_type, testing_site) %>% 
  summarize(
    mean(pct_frl, na.rm = TRUE), 
    mean(pct_black, na.rm = TRUE),
    mean(pct_white, na.rm = TRUE),
    mean(pct_male, na.rm = TRUE),
    mean(pct_tested, na.rm = TRUE),
    mean(erw_mean, na.rm = TRUE),
    mean(math_mean, na.rm = TRUE),
    mean(total_mean, na.rm = TRUE),
    mean(number_times_offered, na.rm = TRUE)
  ) 
averages_by_site_and_location <- averages_by_site_and_location[-c(3,4,7),]
colnames(averages_by_site_and_location) <- c('location_type','testing_site_boolean', 'mean_pct_frl', 'mean_pct_black','mean_pct_white','mean_pct_male','mean_pct_tested', 'mean_erw_score','mean_math_score', 'mean_score', 'mean_times_offered')

# analysis by rating
averages_by_school_rating <- all_school_info %>% 
  group_by(overall_rating) %>% 
  summarize(
    mean(pct_frl, na.rm = TRUE), 
    mean(pct_black, na.rm = TRUE),
    mean(pct_white, na.rm = TRUE),
    mean(pct_male, na.rm = TRUE),
    mean(pct_tested, na.rm = TRUE),
    mean(erw_mean, na.rm = TRUE),
    mean(math_mean, na.rm = TRUE),
    mean(total_mean, na.rm = TRUE),
    mean(number_times_offered, na.rm = TRUE)
  ) 

colnames(averages_by_school_rating) <- c('school_rating', 'mean_pct_frl', 'mean_pct_black','mean_pct_white','mean_pct_male','mean_pct_tested', 'mean_erw_score','mean_math_score', 'mean_score', 'mean_times_offered')
averages_by_school_rating <- averages_by_school_rating[-c(6),]

averages_by_gradrate_rating <- all_school_info %>% 
  group_by(gradrate_rating) %>% 
  summarize(
    mean(pct_frl, na.rm = TRUE), 
    mean(pct_black, na.rm = TRUE),
    mean(pct_white, na.rm = TRUE),
    mean(pct_male, na.rm = TRUE),
    mean(pct_tested, na.rm = TRUE),
    mean(erw_mean, na.rm = TRUE),
    mean(math_mean, na.rm = TRUE),
    mean(total_mean, na.rm = TRUE),
    mean(number_times_offered, na.rm = TRUE)
  ) 
colnames(averages_by_gradrate_rating) <- c('school_gradrate_rating', 'mean_pct_frl', 'mean_pct_black','mean_pct_white','mean_pct_male','mean_pct_tested', 'mean_erw_score','mean_math_score', 'mean_score', 'mean_times_offered')

# lets plot

averages_by_site_and_location_combined <- averages_by_site_and_location %>% 
  mutate(type = 0) %>% 
  ungroup() %>% 
  select(-location_type, -testing_site_boolean) 
  
averages_by_site_and_location_combined$type[1] <- "Rural, No Testing Sites"
averages_by_site_and_location_combined$type[2] <- "Rural, Testing Sites"
averages_by_site_and_location_combined$type[3] <- "Urban, No Testing Sites"
averages_by_site_and_location_combined$type[4] <- "Urban, Testing Sites"

# reshape it - by subgroup rural/urban and testing/no testing
reshape_pcts <- gather(averages_by_site_and_location_combined, outcome, value, mean_pct_frl:mean_pct_tested) %>% 
  select(type, outcome, value)
reshape_scores <- gather(averages_by_site_and_location_combined, outcome, value, mean_erw_score:mean_math_score) %>% 
  select(type, outcome, value)

reshape_scores %>% 
  ggplot(
    aes(x = outcome, y = value, group=type, fill = type)
  ) +
  geom_bar(
    stat = "identity",
    position = position_dodge()
  )  +
  labs(x = element_blank(), y = 'Score', title = 'Average Score on SAT Tests by Subgroup')  +
  ylim(0, 800) +
  scale_x_discrete(labels=c("mean_erw_score" = "Reading and Writing", "mean_math_score" = "Math")) +
  scale_fill_brewer(name = 'Subgroup', palette = "Paired")
)

reshape_pcts %>% 
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
                            "mean_pct_frl" = "Free & Reduced Lunch",
                            "mean_pct_tested" = "Took the SAT")) +
  scale_fill_brewer(name = 'Subgroup', palette = "Paired")


# reshape it by school rating
averages_by_school_rating$school_rating <- as.character(averages_by_school_rating$school_rating)

rating_reshape_pcts <- gather(averages_by_school_rating, outcome, value, mean_pct_frl:mean_pct_tested) %>% 
  select(school_rating, outcome, value) %>% 
  filter(outcome != 'mean_pct_white')

rating_reshape_scores <- gather(averages_by_school_rating, outcome, value, mean_erw_score:mean_math_score) %>% 
  select(school_rating, outcome, value)

rating_reshape_scores %>% 
  ggplot(
    aes(x = outcome, y = value, group=school_rating, fill = school_rating)
  ) +
  geom_bar(
    stat = "identity",
    position = position_dodge()
  )  +
  labs(x = element_blank(), y = 'Score', title = 'Average Score on SAT Tests by School Rating')  +
  ylim(0, 800) +
  scale_x_discrete(labels=c("mean_erw_score" = "Reading and Writing", "mean_math_score" = "Math")) +
  scale_fill_brewer(name = 'Overall Rating', palette = "Spectral", labels=c("Unsatisfactory", "Below Average", "Average", "Good","Excellent"))
)

rating_reshape_pcts %>% 
  ggplot(
    aes(x = outcome, y = value, group=school_rating, fill = school_rating)
  ) +
  geom_bar(
    stat = "identity",
    position = position_dodge()
  )  +
  labs(x = element_blank(), y = 'Percentage', title = 'Demographic Groups by School Rating')  +
  ylim(0, .8) +
  scale_x_discrete(labels=c("mean_pct_black" = "Black", 
                            "mean_pct_frl" = "Free & Reduced Lunch",
                            "mean_pct_tested" = "Took the SAT",
                            "mean_pct_male" = "Male")) +
  scale_fill_brewer(name = 'Overall Rating', palette = "Spectral", labels=c("Unsatisfactory", "Below Average", "Average", "Good","Excellent"))

## attempting to test for statistical significance

testing_sites <- all_school_info %>% 
  filter(testing_site == 1)

not_testing_sites <- all_school_info %>% 
  filter(testing_site == 0)

t.test(not_testing_sites$total_enrollment, testing_sites$total_enrollment)

t.test(not_testing_sites$pct_male, testing_sites$pct_male)

t.test(not_testing_sites$pct_black, testing_sites$pct_black)

t.test(not_testing_sites$pct_frl, testing_sites$pct_frl)

t.test(not_testing_sites$pct_tested, testing_sites$pct_tested)

t.test(not_testing_sites$gradrate_rating, testing_sites$gradrate_rating)

all_school_info %>% 
  group_by(testing_site)
  summarize(
    mean(pct_frl, na.rm = TRUE), 
    mean(pct_black, na.rm = TRUE),
    mean(pct_white, na.rm = TRUE),
    mean(pct_male, na.rm = TRUE),
    mean(pct_tested, na.rm = TRUE),
    mean(erw_mean, na.rm = TRUE),
    mean(math_mean, na.rm = TRUE),
    mean(total_mean, na.rm = TRUE),
    mean(total_enrollment, na.rm = TRUE),
    mean(overall_rating, na.rm = TRUE),
    mean(achievement_rating, na.rm = TRUE),
    mean(gradrate_rating, na.rm =TRUE)
  )
  
  averages_by_testing_site <- all_school_info %>% 
    group_by(testing_site) %>% 
    summarize(
      mean(pct_frl, na.rm = TRUE), 
      mean(pct_black, na.rm = TRUE),
      mean(pct_white, na.rm = TRUE),
      mean(pct_male, na.rm = TRUE),
      mean(pct_tested, na.rm = TRUE),
      mean(erw_mean, na.rm = TRUE),
      mean(math_mean, na.rm = TRUE),
      mean(total_mean, na.rm = TRUE),
      mean(total_enrollment, na.rm = TRUE),
      mean(overall_rating, na.rm = TRUE),
      mean(achievement_rating, na.rm = TRUE),
      mean(gradrate_rating, na.rm =TRUE)
    ) 
  
colnames(averages_by_testing_site) <- c('testing_site_boolean', 'pct_frl', 'pct_black','pct_white','pct_male','pct_tested', 'erw_score','math_score', 'total_score', 'total_enrollment',"overall_rating","achievement_rating","gradrate_rating")
  
averages_by_testing_site <- data.frame(t(averages_by_testing_site))
averages_by_testing_site <- averages_by_testing_site[-1,]

averages_by_testing_site <- cbind(newColName = rownames(averages_by_testing_site), averages_by_testing_site)
rownames(averages_by_testing_site) <- 1:nrow(averages_by_testing_site)

colnames(averages_by_testing_site) <- c("variable","mean_not_testing_sites","mean_testing_sites")


t.test(not_testing_sites$gradrate_rating, testing_sites$gradrate_rating)[['p.value']]

t_testing <- function(var1) {
  df1 <- not_testing_sites
  df2 <- testing_sites
  p_value <- t.test(df1[[var1]], df2[[var1]])[['p.value']]
  return(p_value)
}  

averages_by_testing_site[1,4] <- t_testing('pct_frl') 
averages_by_testing_site[2,4] <- t_testing('pct_black') 
averages_by_testing_site[3,4] <- t_testing('pct_white') 
averages_by_testing_site[4,4] <- t_testing('pct_male') 
averages_by_testing_site[5,4] <- t_testing('pct_tested') 
averages_by_testing_site[6,4] <- t_testing('erw_mean') 
averages_by_testing_site[7,4] <- t_testing('math_mean') 
averages_by_testing_site[8,4] <- t_testing('total_mean') 
averages_by_testing_site[9,4] <- t_testing('total_enrollment') 
averages_by_testing_site[10,4] <- t_testing('overall_rating') 
averages_by_testing_site[11,4] <- t_testing('achievement_rating') 
averages_by_testing_site[12,4] <- t_testing('gradrate_rating') 

colnames(averages_by_testing_site) <- c("variable","mean_not_testing_sites","mean_testing_sites","p_value")

averages_by_testing_site <- averages_by_testing_site %>% 
  mutate(p_significance = case_when(
    p_value < 0.05 ~ "Significant",
    p_value >= 0.05 ~ "Not Significant"
  ))


all_school_info <- na.omit(all_school_info)
