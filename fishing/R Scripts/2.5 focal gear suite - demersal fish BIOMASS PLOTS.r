rm(list=ls())
library(tidyverse)

Domains <- readRDS("./Objects/Domains.RDS") #load domains polygon
wholedomain_area <- sum(Domains$area)#sum areas
biomass2010 <- readRDS("./fishing/fishing bounds/changingpower/suite experiment/2010-2019/objects/Biomass 2010.rds") #load in 2010s biomasses
biomass2090 <- readRDS("./fishing/fishing bounds/changingpower/suite experiment/2090-2099/objects/Biomass 2090.rds") #load in 2090s biomasses
guilds <- c("Planktivorous_fish","Birds","Cetaceans","Demersal_fish","Migratory_fish","Pinnipeds")
guildbiom2010 <- dplyr::filter(biomass2010,Description %in% guilds) #filter down to selected guild biomass
guildbiom2090 <- dplyr::filter(biomass2090,Description %in% guilds)#filter down to selected guild biomass

#define vector of nitrogen to WW conversions (same order as DF)
conversions <- c(2.037735849,2.51572327,2.51572327,1.295597484,2.314465409,2.51572327)
guildbiom2010$conversion <- rep(conversions,nrow(guildbiom2010)/length(conversions))
guildbiom2010$Model_annual_mean <- wholedomain_area * (guildbiom2010$Model_annual_mean/guildbiom2010$conversion)/1000000 #converts to tonnes of wet weight
#add year col
guildbiom2010$Year <- "2010"

guildbiom2090$conversion <- rep(conversions,nrow(guildbiom2090)/length(conversions))
guildbiom2090$Model_annual_mean <- wholedomain_area * (guildbiom2090$Model_annual_mean/guildbiom2090$conversion)/1000000
guildbiom2090$Year <- "2090"

guildbiomass <- rbind(guildbiom2010,guildbiom2090)
guildbiomass$Focal.Multiplier <- rep(seq(0,4,0.01),each = length(guilds))

d_rect <- data.frame(
  ymin = c(0, 0, 0, 0, 0, 0, 0),
  ymax = c(570, 32500, 1200000, 160, 9700, 1000, 100000),
  xmin = rep(0, times = 7),
  xmax = rep(1, times = 7)
)


ggplot(data = guildbiomass)+
  geom_point(aes(x = `Focal Multiplier`,
                 y = Model_annual_mean,
                 color = Year),size = 0.8, stroke = 0, shape = 16) +
  labs(x = "Gear Multiplier",
       y = "Total Biomass in system (Tonnes wet weight)",color = "Year") +
  scale_x_continuous(expand = c(0,0)) +
  scale_y_continuous(expand = c(0,0)) +
  scale_color_manual(values = c("#E2741D", "#1D8BE2"))+
  geom_smooth(aes(x = `Focal Multiplier`,
                               y = Model_annual_mean,
                               color = Year),
              alpha = 0.6,
              method = "loess",
              se = FALSE) +
  #ggtitle("Biomass of Demersal Fish (tonnes wet weight) using a Suite of Gears as Focal Multipliers") +
  guides(colour = guide_legend(override.aes = list(size=3))) +
  theme(axis.text.x = element_text(size = 24,color = "white"),
        axis.text.y = element_text(size = 24,color = "white"),
        axis.title = element_text(size = 24,color = "white"),
        legend.title = element_text(size=24,color = "white"), #change legend title font size
        legend.text = element_text(size=24,color = "white"),
        strip.text = element_text(
          size = 24, color = "white"),
        strip.background = element_rect(fill = "#081a24"),
        rect = element_rect(fill = "transparent"),
        panel.border = element_blank(),
        plot.background = element_rect(color = NA)) +
  #theme_light() +
  # facet_wrap(~Description,scales = "free_y",ncol = 2) +
  facet_wrap(~factor(Description,levels = c("Birds","Demersal_fish","Pinnipeds","Planktivorous_fish","Cetaceans","Migratory_fish")),scales = "free_y",ncol = 2) +
  NULL

##Add to more plots in, so there is nine, and have 3 columns
ggsave("./fishing/fishing bounds/changingpower/suite experiment/2010-2019/figures/BiomassFacet.png",width = 33.867,height = 19.05,units = "cm",bg = 'transparent')
