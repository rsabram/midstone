setwd('/Users/rabram/Desktop/NSS/midstone')
library(tidyverse)
library(ggplot2)

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
merge_1 <- merge(sat_scores_clean, report_cards_clean, by = 'SID') %>% 
  select(-school.y, -grade_levels)
merge_2 <- merge(merge_1, adm_clean, by = 'SID') %>% 
  select(-district.y, -school)
school_info <- merge(merge_2, frl_clean, by = 'SID')

# clean the merge
school_info <- school_info %>% 
  select(-district, -school, -no_seniors, -black, -ai, -white, -aa, -hispanic, -hawaiian, -two_or_more, -total_enrollment, -frl_enrollment, -female) %>% 
  mutate(pct_male = male/total) %>% 
  select(-male)

colnames(school_info) <- c('SID','school','district','no_seniors_tested','pct_seniors_tested', 'sat_ewr_mean','sat_math_mean','sat_score_mean','school_rating_overall','school_rating_achievement','school_rating_gradrate','total_enrollment','pct_black','pct_white', 'location_type','pct_frl','pct_male')
