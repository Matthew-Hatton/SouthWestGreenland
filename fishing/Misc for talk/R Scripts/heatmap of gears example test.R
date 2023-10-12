library(tidyverse)
library(ggplot2)
library(paletteer)


macs <- c(1,2,3,4,5,6)
KP <- c(4,5,6,7,8,2)
PF <- c(4,6,8,9,3,1)
Gears <- c("PelTrawl","DemTrawl","KelpHarv","DemSeine","Rifles","Nets")

df <- data.frame(Gears,macs,KP,PF)

df <- pivot_longer(df,cols = c("macs","KP","PF"),names_to = "Guild")

ggplot() +
  geom_tile(df,mapping = aes(x = Guild,y = Gears,fill = value)) +
  paletteer::scale_fill_paletteer_c("ggthemes::Orange") +
  scale_x_discrete(expand = c(0,0)) +
  scale_y_discrete(expand = c(0,0)) +
  labs(fill = "Power")
