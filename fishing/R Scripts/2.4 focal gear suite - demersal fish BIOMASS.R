rm(list = ls()) #fresh start
#setwd("output3\\discards")
library(ggplot2)
library(tidyverse)
library(furrr)
library(tictoc)
library(gtools)
library(data.table)
library(gsubfn)

tic("Mapping the dataframe") #time
plan("multisession") #setup parallel processing
setwd("C:/Users/psb22188/Documents/PhD/22-23/West Greenland/NEMO/Data Wrangling/Jacks Way/fishing/fishing bounds/changingpower/suite experiment/2010-2019/biomass")
scaling <- seq(0,4,0.01) #define scale factors from focal gear file
files <- list.files()
files2 <- mixedsort(sort(files))#sort the files
master <- read.csv("../masterDemFishdataframe.csv") %>% 
  dplyr::select(-1) #load in master dataframe and delete the row index

result_lst <- future_map(.x = files2,.f = readRDS,.progress = TRUE) %>% #apply readRDS to files in parallel
  lapply(function(x) as.data.frame(x)) %>% #transform into df
  mapply(`[<-`, ., 'SimulationID', value = rep(master$SimulationID),
         SIMPLIFY = FALSE) %>% #adds simulation ID to each dataframe
  mapply(`[<-`, ., 'Focal Multiplier', value = rep(scaling),
         SIMPLIFY = FALSE)#adds focal multiplier
toc()


biomass2010_result <- do.call(rbind,result_lst) 

saveRDS(biomass2010_result,"../objects/Biomass 2010.rds")
