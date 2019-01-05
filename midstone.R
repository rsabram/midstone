setwd('/Users/rabram/Desktop/NSS/midstone')
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


## START ANALYSIS HERE ->




