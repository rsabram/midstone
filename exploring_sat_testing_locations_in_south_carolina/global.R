library(tidyverse)
library(ggplot2)
library(shinydashboard)
library(shiny)
library(plotly)

testing_sites <- readRDS('./data/testing_sites.RDS')
not_testing_sites <- readRDS('./data/not_testing_sites.RDS')
averages_by_site_and_location <- readRDS('./data/averages_by_site_and_location.RDS')
testing_site_t_tests <- readRDS('./data/t_tests.RDS')
all_school_info <- readRDS("./data/shiny_dt.RDS")

variables <- unique(averages_by_site_and_location$outcome)

theme_set(theme_grey(base_size = 18)) 
 