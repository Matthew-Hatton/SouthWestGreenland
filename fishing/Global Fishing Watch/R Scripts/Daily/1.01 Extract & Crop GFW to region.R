#A script which will crop global fishing watch data to my region of interest
rm(list=ls()) #reset
library(tidyverse)
library(furrr)
library(sf)
library(dplyr)
plan(multisession)
sf_use_s2(FALSE) #turn off spherical geometry

source("./fishing/Global Fishing Watch/R Scripts/Daily/Functions/RoughCrop.R") #loads crop function

#specify year
year <- 2013 

files <- list.files(path = paste0("./fishing/Global Fishing Watch/RAW/Daily/",year,"/fleet-daily-csvs-100-v2-",year),
                    full.names = TRUE) #list all year files
all_files <- future_map(files,read.csv,
                        .progress = TRUE) #read in all files from that year

all_files <- lapply(all_files,crop) #crops down those files

all_data <- do.call(rbind.data.frame,all_files) #merges to one dataframe
write.csv(all_data,paste0("./fishing/Global Fishing Watch/finished data/",year,"/GFW_",year,".csv"),row.names = FALSE)