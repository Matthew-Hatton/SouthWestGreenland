rm(list = ls()) #fresh start
setwd("~/PhD/22-23/West Greenland/NEMO/Data Wrangling/Jacks Way/fishing/fishing bounds/changingpower")
library(ggplot2)
library(tidyverse)
master <- read.csv("mastercombinationsdf.csv") %>% #loads in master df
  .[,-1]
load("alldf.RData") #loads in df's for plotting
load("landingsdf.RData")
load("discardsdf.RData")
# filt <- dplyr::filter(.data = finalgears,Gear == c("Rifles")) %>% 
#   dplyr::filter(Guild == "Pinnipeds")
# 
notquota <- dplyr::filter(.data = finalgears,Guild !="Quota-limited demersal fish",Guild != "Macrophytes",
                          Guild != "Non-quota demersal fish",Guild != "Carn/scavenge feeding benthos",
                          Guild != "Migratory fish")

planktivpinn <- dplyr::filter(.data = finalgears,Guild == c("Cetaceans"))
nomacros <- dplyr::filter(.data = finalgears,Guild != "Macrophytes")

tic("Plotting the results")
ggplot()+
  geom_point(data = nomacros,
             aes(x = Focal.Multiplier,
                 y = Catch,
                 color = Focal.Gear),size = 0.3, stroke = 0, shape = 16) +
  #geom_line(data = rifles,aes(x = Focal.Multiplier,y = Catch)) +
  facet_wrap(~Guild,scales = "free_y") +
  #facet_wrap(~Guild) + #for when the scales are the same
  theme(strip.text = element_text(size = 5),legend.title = element_text(size = 5), 
        legend.text = element_text(size = 5)) +
  guides(colour = guide_legend(override.aes = list(size=2)),shape = guide_legend(override.aes = list(size = 0.75))) +
  labs(x = "Focal Gear Multiplier",y = "Total Catch") +
  scale_x_continuous(expand = c(0,0))+
  scale_y_continuous(expand = c(0,0)) +
  NULL
ggsave(paste0("output3\\allfig\\Catch of Planktivorous fish by Focal gear.png")) #save
toc()

