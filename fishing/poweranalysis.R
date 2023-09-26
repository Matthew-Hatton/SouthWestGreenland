rm(list = ls()) #fresh start
#setwd("../discards")
library(ggplot2)
library(tidyverse)
library(furrr)
library(tictoc)

tic() #time
plan("multisession") #setup parallel processing

files <- list.files() #lists files - need to set wd first


result_lst <- future_map(.x = files,.f = readRDS,.progress = TRUE) #apply readRDS to files in parallel
final <- data.frame()

#removed ,"Quota-limited demersal fish" and "Carn/scavenge feeding benthos" ,"Cetaceans" ,"Non-quota demersal fish" 
# for scale,"Migratory fish"
investigating <- c("Pelagic invertebrates",
                   "Birds","Quota-limited demersal fish","Carn/scavenge feeding benthos" ,"Cetaceans" ,"Non-quota demersal fish" ,
                   "Migratory fish","Susp/deposit feeding benthos","Planktivorous fish","Macrophytes","Pinnipeds")
for(i in 1:length(investigating)){
  guild <- lapply(result_lst, function(result_lst) subset(result_lst, row.names(result_lst) == investigating[i]))  #subsets to just one guild
  
  result <- do.call(rbind,guild) %>% #adds guilds
    data.frame() #turns in to a dataframe
  row.names(result) <- sub("\\.rds.*", "", files) #extract number and zone
  result <- cbind(guild = investigating[i]) %>% 
    cbind(zone = sub(".*_","",row.names(result)),result) %>%  #gets zone and adds to df
    cbind(multiplier = as.numeric(sub("\\_.*","",files)),.)
  row.names(result) <- NULL #reset rownames
  
  result$total <- rowSums(result[,4:15]) #calculates total
  
  final <- rbind(final,result)
  print(paste0(i,"/",length(investigating)))
}

# result <- pivot_longer(result,cols = c("Pelagic_trawl.seine","Demersal_otter_trawl",
#                                     "Demersal_seine","Gill_nets","Longlines.and.Jiggiing","Recreational","Shrimp_trawl",
#                                     "Creels","Mollusc_dredge","Harpoons","Rifles","Kelp_harvester" ),
#                     names_to = c("Gear")) #turns gear columns into values inside df


ggplot() +
  geom_point(data = final,aes(x = multiplier,y = total,color = zone),size = 0.1, stroke = 0, shape = 16)  +
  #ggtitle(paste0("Catch of ",investigating, " using varying gear multipliers")) +
  guides(colour = guide_legend(override.aes = list(size=5))) +
  labs(y = "Discards (mMN.y⁻¹)",x = "Gear Multiplier",color = "Zone") +
  #ggtitle(paste0(investigating))+
  #theme(plot.title=element_text(margin=margin(t=40,b=-30))) +
  facet_wrap(~guild,scales = "free_y") +
  theme(strip.text = element_text(size = 5))
  NULL #plots
#rm(guild,result_lst,files,investigating) #remove unwanted
ggsave(paste0("..\\discards of varying guilds.png")) #save
toc()



