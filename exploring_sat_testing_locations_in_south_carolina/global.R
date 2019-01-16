library(tidyverse)
library(ggplot2)
library(shinydashboard)
library(shiny)
library(plotly)

testing_sites <- readRDS('./data/testing_sites.RDS')
not_testing_sites <- readRDS('./data/not_testing_sites.RDS')
averages_by_site_and_location <- readRDS('./data/averages_by_site_and_location.RDS')
testing_site_t_tests <- readRDS('./data/testing_site_t_tests.RDS')
all_school_info <- readRDS("./data/all_school_info.RDS")

all_school_info <- all_school_info %>% 
  select(school, district, location_type, total_enrollment, pct_frl, pct_tested, testing_site) %>% 
  na.omit()

variables <- unique(averages_by_site_and_location$outcome)

theme_set(theme_grey(base_size = 18)) 
 