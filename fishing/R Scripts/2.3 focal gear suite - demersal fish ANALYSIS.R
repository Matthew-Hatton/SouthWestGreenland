rm(list = ls()) #fresh start
setwd("~/PhD/22-23/West Greenland/NEMO/Data Wrangling/Jacks Way/fishing/fishing bounds/changingpower")
library(ggplot2)
library(tidyverse)
library(tictoc)
library(zoo)
Domains <- readRDS("../../../Objects/Domains.RDS") #load domains polygon
wholedomain_area <- sum(Domains$area)#sum areas
scaling <- seq(0,4,0.01)
master <- read.csv("./suite experiment/2010-2019/masterDemFishdataframe.csv") %>% #loads in master df
  .[,-1]
gears <- c("Pelagic_trawl.seine","Demersal_otter_trawl","Demersal_seine","Longlines.and.Jiggiing")
#already filtered to demersalfish
finalcatch2010 <- readRDS("./suite experiment/2010-2019/objects/finalcatch2010.Rds") #loads in df's for plotting
finalcatchgears2010 <- readRDS("./suite experiment/2010-2019/objects/finalcatchgears2010.Rds") %>% 
  filter(.,Gear %in% gears)

finalcatch2090 <- readRDS("./suite experiment/2090-2099/objects/finalcatch2090.Rds")
finalcatchgears2090 <- readRDS("./suite experiment/2090-2099/objects/finalcatchgears2090.Rds") %>% 
  filter(.,Gear %in% gears)

#full aggregation of 2010 values. WHOLEDOMAIN, BOTH GUILDS OF DEMERSAL FISH, ACROSS ALL GEARS WHICH CATCH
quota <- filter(finalcatchgears2010,Guild == "Quota-limited demersal fish") #filter quota demersal fish 2010
total_quota2010 <- rowsum(quota$Catch,rep(1:401,each = 8)) #sum zones and gears total catch

nonquota <- filter(finalcatchgears2010,Guild == "Non-quota demersal fish") #filter non-quota demersal fish 2010
total_nonquota2010 <- rowsum(nonquota$Catch,rep(1:401,each = 8)) #sum zones and gears total catch

quota2090 <- filter(finalcatchgears2090,Guild == "Quota-limited demersal fish")#filter quota demersal fish 2090
total_quota2090 <- rowsum(quota2090$Catch,rep(1:401,each = 8))#sum zones and gears total catch 2090

nonquota2090 <- filter(finalcatchgears2090,Guild == "Non-quota demersal fish")#filter non-quota demersal fish 2090
total_nonquota2090 <- rowsum(nonquota2090$Catch,rep(1:401,each = 8))#sum zones and gears total catch 2090

final2010 <- (total_quota2010+total_nonquota2090) %>% #sums vectors to give total of the two guilds
  data.frame(Focal.Multiplier = scaling,Total.Catch.2010 = .) #converts to df #adds in year column


final2090 <- total_quota2090+total_nonquota2090 %>% 
  data.frame(x = scaling,y = .)
colnames(final2090) <- c("Focal.Multiplier","Total.Catch.2090")

final2090$Total.Catch.2090[380:401] <- NA #fix model break
final <- cbind(final2010,final2090) %>%  #combine dfs
  pivot_longer(cols = c("Total.Catch.2010","Total.Catch.2090"),names_prefix = "Total.Catch.",names_to = "year")#convert df to long format
final$Focal.Multiplier <- rep(seq(0,4,0.01),each = 2)

#convert to wet weight
final$value <- wholedomain_area * (final$value/1.295597484)/1000000

tic("Plotting the results")
ggplot()+
  geom_point(data = final,
             aes(x = Focal.Multiplier,
                 y = value,
                 color = year),size = 0.5) +
  #labs(x = "Multiplier Demersal otter trawl, Demersal seine, Pelagic trawl and seine, Longlines and Jigging",
  #     y = "Total Catch",color = "Year") +
  labs(x = "Gear Multiplier",
       y = "Total Catch (Tonnes wet weight)",color = "Year") +
  scale_x_continuous(expand = c(0,0)) +
  scale_y_continuous(expand = c(0,0)) +
  scale_color_manual(values = c("#E2741D", "#1D8BE2"))+
  geom_smooth(data = final,aes(x = Focal.Multiplier,
                                 y = value,
                                 color = year),
              se=FALSE) +
  
  theme(axis.text.x = element_text(size = 24,color = "white"),
        axis.text.y = element_text(size = 24,color = "white"),
        axis.title = element_text(size = 24,color = "white"),
        legend.title = element_text(size=24,color = "white"), #change legend title font size
        legend.text = element_text(size=24,color = "white"),
        strip.text = element_text(
          size = 14, color = "white"),
        strip.background = element_rect(fill = "#081a24"),
        rect = element_rect(fill = "transparent"),
        plot.background = element_rect(color = NA)) +
  NULL
ggsave("./suite experiment/2010-2019/figures/Demersal fish catch.png",width = 33.867,height = 19.05,units = "cm",bg = 'transparent') #save
toc()

