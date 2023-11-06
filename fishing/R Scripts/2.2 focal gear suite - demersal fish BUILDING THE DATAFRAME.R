rm(list = ls()) #fresh start
#setwd("output3\\discards")
library(ggplot2)
library(tidyverse)
library(furrr)
library(tictoc)
library(gtools)
library(gsubfn)

tic("Mapping the dataframe") #time
plan("multisession") #setup parallel processing
setwd("C:/Users/psb22188/Documents/PhD/22-23/West Greenland/NEMO/Data Wrangling/Jacks Way/fishing/fishing bounds/changingpower/suite experiment/2010-2019/catch")
scaling <- seq(0,4,0.01) #define scale factors from focal gear file
files <- list.files()
files2 <- mixedsort(sort(files))#sort the files
master <- read.csv("../masterDemFishdataframe.csv") %>% 
  select(-1) #load in master dataframe and delete the row index

result_lst <- future_map(.x = files2,.f = readRDS,.progress = TRUE) %>% #apply readRDS to files in parallel
  lapply(function(x) as.data.frame(x)) %>% #transform into df
  mapply(`[<-`, ., 'SimulationID', value = rep(master$SimulationID,each = 2),
         SIMPLIFY = FALSE) %>% #adds simulation ID to each dataframe
  mapply(`[<-`, ., 'Zone', value = rep(c("Inshore","Offshore"),length(files2)/2),
         SIMPLIFY = FALSE) %>% #adds inshore/offshore columns
  mapply(`[<-`, ., 'Focal Multiplier', value = rep(scaling,each = 2),
         SIMPLIFY = FALSE)#adds focal multiplier
toc()
tic("Building the dataframe")
finalcatch <- data.frame() #empty df
investigating <- c("Quota-limited demersal fish" ,"Non-quota demersal fish")
for(i in 1:length(investigating)){
  guild <- lapply(result_lst, function(result_lst) subset(result_lst, row.names(result_lst) == investigating[i]))  #subsets to just one guild
  
  result <- do.call(rbind,guild) %>% #adds guilds
    data.frame() #turns in to a dataframe
  result <- cbind(Guild = investigating[i],result)
  row.names(result) <- NULL #reset rownames
  
  result$Total <- rowSums(result[,3:13]) #calculates total
  
  finalcatch <- rbind(finalcatch,result) #bind all together
  print(paste0(i,"/",length(investigating))) #progress
}
row.names(finalcatch) <- NULL #reset rownames

toc()
cols <- colnames(finalcatch)[2:13]
finalcatchgears <- pivot_longer(data = finalcatch,cols = cols,
                                   names_to = "Gear",
                                   values_to = "Catch")

toc()
rm(cols,files,files2,i,investigating,scaling,result_lst,result,master,guild)
saveRDS(finalcatch,file = "../objects/finalcatch2010.Rds")
saveRDS(finalcatchgears,file = "../objects/finalcatchgears2010.Rds")
