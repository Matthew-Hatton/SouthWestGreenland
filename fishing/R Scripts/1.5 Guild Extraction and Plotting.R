rm(list=ls()) #reset
library(ggplot2)
library(tidyverse)
library(gsubfn)

#read in df
biomass_df <- readRDS(file = "fishing/fishing bounds/changingpower/biomassoutputs/biomass DF.Rds")

#rifles and pinnipeds
toplt <- biomass_df[biomass_df$Description == "Planktivorous_fish",] %>% 
  .[.$`Focal Gear` == "Pelagic_trawl+seine.rds",]

ggplot()+
  geom_rect(aes(xmin = 0,xmax = 1,ymin = 0,ymax=max(toplt$Model_annual_mean)),alpha = 0.1,color = "grey98") +
  geom_point(data = toplt,
             aes(x = `Focal Multiplier`,
                 y = Model_annual_mean,
                 color = Zone),size = 1, stroke = 0, shape = 16) +
  #facet_wrap(~Zone,scales = "free_y") +
  #facet_wrap(~Guild) + #for when the scales are the same
  geom_smooth(data = toplt,aes(x = `Focal Multiplier`,
                               y = Model_annual_mean,
                               color = Zone)) +
  theme(strip.text = element_text(size = 5),legend.title = element_text(size = 5), 
        legend.text = element_text(size = 5)) +
  guides(colour = guide_legend(override.aes = list(size=2)),shape = guide_legend(override.aes = list(size = 0.75))) +
  labs(x = "Focal Gear Multiplier (Gill Nets)",y = "Model Annual Mean") +
  scale_x_continuous(expand = c(0,0))+
  scale_y_continuous(expand = c(0,0)) +
  scale_color_manual(values = c("#E2741D", "#1D8BE2")) +
  NULL
ggsave("fishing/fishing bounds/changingpower/biomassoutputs/plots/PlanktivorousFishBiomass.png")
