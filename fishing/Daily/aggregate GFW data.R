#aggregate GFW data
rm(list = ls()) #fresh start

library(furrr)
library(tidyverse)

#read in GFW summarise data
files <- list.files(path = "./fishing/Global Fishing Watch/finished data",
                    full.names = TRUE)
all_files <- future_map(files,read.csv,
                        .progress = TRUE)
all_data <- do.call(rbind.data.frame,all_files)

#filter individual gears + sum
fishing <- filter(all_data,all_data$geartype == "fishing")
fishing_total <- sum(fishing$total_fishing_hours)/8 #/8 because 8 years (2012-2019)

set_longlines <- filter(all_data,all_data$geartype == "set_longlines")
set_longlines_total <- sum(set_longlines$total_fishing_hours)/8

trawlers <- filter(all_data,all_data$geartype == "trawlers")
trawlers_total <- sum(trawlers$total_fishing_hours)/8

other_purse_seines <- filter(all_data,all_data$geartype == "other_purse_seines")
other_purse_seines_total <- sum(other_purse_seines$total_fishing_hours)/8

fixed_gear <- filter(all_data,all_data$geartype == "fixed_gear")
fixed_gear_total <- sum(fixed_gear$total_fishing_hours)/8

set_gillnets <- filter(all_data,all_data$geartype == "set_gillnets")
set_gillnets_total <- sum(set_gillnets$total_fishing_hours)/8

fishing_activity_df <- data.frame(gear = c("fishing","set_longlines","trawlers","other_purse_seines","fixed_gear","set_gillnets"),
                                  Activity_.s.m2.d. = c(fishing_total,set_longlines_total,trawlers_total,other_purse_seines_total,
                                                        fixed_gear_total,set_gillnets_total)) #builds final df

write.csv(fishing_activity_df,"./fishing/Global Fishing Watch/finished data/fishing_activity_SWG_BADGears.csv",row.names = FALSE) #saves
