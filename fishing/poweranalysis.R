rm(list = ls()) #fresh start
#setwd("./catch")
library(ggplot2)
library(tidyverse)
library(furrr)
library(tictoc)

tic() #time
plan("multisession") #setup parallel processing
#need to preserve names
files <- list.files() #lists files - need to set wd first
investigating <- "Cetaceans" #change depending on guild

result_lst <- future_map(.x = files,.f = readRDS,.progress = TRUE)  #apply readRDS to files in parallel
guild <- lapply(result_lst, function(result_lst) subset(result_lst, row.names(result_lst) == investigating))  #subsets to just one guild

result <- do.call(rbind,guild) %>% #adds guilds
  data.frame() #turns in to a dataframe
row.names(result) <- sub("\\.rds.*", "", files) #extract number and zone
result <- cbind(guild = investigating) %>% 
            cbind(zone = sub(".*_","",row.names(result)),result) %>%  #gets zone and adds to df
              cbind(multiplier = as.numeric(sub("\\_.*","",files)),.)
row.names(result) <- NULL #reset rownmaes
result <- pivot_longer(result,cols = c("Pelagic_trawl.seine","Demersal_otter_trawl",
                                    "Demersal_seine","Gill_nets","Longlines.and.Jiggiing","Recreational","Shrimp_trawl",
                                    "Creels","Mollusc_dredge","Harpoons","Rifles","Kelp_harvester" ),
                    names_to = c("Gear")) #turns gear columns into values inside df


ggplot() +
  geom_point(data = result,aes(x = multiplier,y = value,color = Gear),size = 0.1) +
  ggtitle(paste0("Catch of ",investigating, " using varying gear multipliers")) +
  guides(colour = guide_legend(override.aes = list(size=5))) +
  labs(y = "Catch (mMN.y⁻¹)",x = "Gear Multiplier") #plots
#rm(guild,result_lst,files,investigating) #remove unwanted
ggsave("catch of cetaceans.png")
toc() #time
