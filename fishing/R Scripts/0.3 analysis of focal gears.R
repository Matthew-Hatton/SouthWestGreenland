rm(list = ls()) #fresh start
setwd("~/PhD/22-23/West Greenland/NEMO/Data Wrangling/Jacks Way/fishing/fishing bounds/changingpower")
library(ggplot2)
library(tidyverse)
library(tictoc)
master <- read.csv("mastercombinationsdf.csv") %>% #loads in master df
  .[,-1]
load("alldf.RData") #loads in df's for plotting
load("landingsdf.RData")
load("discardsdf.RData")
# filt <- dplyr::filter(.data = finalgears,Gear == c("Rifles")) %>% 
#   dplyr::filter(Guild == "Pinnipeds")
# 
target_guild <- c("Planktivorous fish")
DemFish <- dplyr::filter(.data = finallandingsgears,Guild == target_guild,Focal.Gear == "Pelagic_trawl+seine",Gear == "Pelagic_trawl.seine")

tic("Plotting the results")
ggplot()+
  geom_rect(aes(xmin = 0,xmax = 1,ymin = max(DemFish$Catch),ymax=max(DemFish$Catch)),alpha = 0.1,color = "grey98") +
  geom_point(data = DemFish,
             aes(x = Focal.Multiplier,
                 y = Catch,
                 color = Zone),size = 0.5, stroke = 0, shape = 16) +
  #facet_wrap(~Guild,scales = "free_y") +
  #facet_wrap(~Guild) + #for when the scales are the same
  theme(strip.text = element_text(size = 5),legend.title = element_text(size = 5), 
        legend.text = element_text(size = 5),
        axis.title=element_text(size=5)) +
  guides(colour = guide_legend(override.aes = list(size=2)),shape = guide_legend(override.aes = list(size = 0.75))) +
  labs(x = "Focal Gear Multiplier (Pelagic Trawl)",y = "Total Landings") +
  scale_x_continuous(expand = c(0,0)) +
  scale_y_continuous(expand = c(0,0)) +
  scale_color_manual(values = c("#E2741D", "#1D8BE2"))+
  geom_smooth(data = DemFish,aes(x = Focal.Multiplier,
                               y = Catch,
                               color = Zone)) +
  NULL
ggsave("PlankFishlandingsFocal.png",height = 6.47,width = 11.01,units = "cm") #save
toc()

