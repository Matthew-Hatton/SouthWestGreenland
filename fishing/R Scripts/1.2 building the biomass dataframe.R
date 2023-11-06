rm(list = ls()) #reset
library(tidyverse)
library(furrr)
library(tictoc)
library(gtools)
library(gsubfn)
load("fishing/fishing bounds/changingpower/alldf.RData") #loads in df's for plotting
scaling <- seq(0,4,0.01) #define scale factors from focal gear file
master <- read.csv("fishing/fishing bounds/changingpower/mastercombinationsdf.csv") %>% #loads in master df
  .[,-1]

#inshore
files <- list.files("~/PhD/22-23/West Greenland/NEMO/Data Wrangling/Jacks Way/fishing/fishing bounds/changingpower/biomassoutputs/inoff",full.names = TRUE) #lists files - need to set wd first
files2 <- mixedsort(sort(files)) #sort the files

biomass_lst <- future_map(.x = files2,.f = readRDS,.progress = TRUE) %>% #apply readRDS to files in parallel
  lapply(function(x) as.data.frame(x)) %>% 
  mapply(`[<-`, ., 'SimulationID', value = master$SimulationID,
                                             SIMPLIFY = FALSE) %>% #adds simulation ID to each dataframe
  mapply(`[<-`, ., 'Zone', value = rep(c("Inshore","Offshore"),length(files2)/2),
         SIMPLIFY = FALSE) %>% #adds inshore/offshore columns
  mapply(`[<-`, ., 'Focal Gear', value = gsub(".*shore_","",files2),
         SIMPLIFY = FALSE)#adds filenames

saveRDS(biomass_lst,file = "fishing/fishing bounds/changingpower/biomassoutputs/biomass_list.Rds")

