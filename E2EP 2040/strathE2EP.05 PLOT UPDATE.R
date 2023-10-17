#### physics #### 
library(tidyverse)
library(ggplot2)
new <- read.csv("Models/SW_Greenland/2090-2099/Driving/physics_SWG_2090-2099.csv") %>%   # Read in example boundary drivers
  select(SO_IceFree, SI_IceFree, SO_IceCover, SI_IceCover, SO_IceThickness,SO_temp, D_temp, SI_temp, log10Kvert,SI_IceThickness) %>% 
  mutate(Month = 1:12) %>% 
  pivot_longer(!Month, names_to = "Var", values_to = "Value") %>% 
  mutate(Model = "SW Greenland 2090")

comparison <- read.csv("Models/SW_Greenland/2011-2019/Driving/physics_SWG_2011-2019.csv") %>% 
  select(SO_IceFree, SI_IceFree, SO_IceCover, SI_IceCover, SO_IceThickness,SO_temp, D_temp, SI_temp, log10Kvert,SI_IceThickness) %>% 
  mutate(Month = 1:12) %>% 
  pivot_longer(!Month, names_to = "Var", values_to = "Value") %>% 
  mutate(Model = "SW Greenland 2010") %>% 
  bind_rows(new)

#compare only driving data which is breaking the model
# facets <- c("SI_IceFree","SI_IceThickness","SO_IceThickness")
# comparison <- filter(comparison,Var %in% facets)


ggplot() +
  geom_line(data = comparison, aes(x = Month, y = Value, colour = Model)) +
  #theme_minimal() +
  facet_wrap(vars(Var), scales = "free_y")
ggsave("./Figures and Data/Figures/ModelBreakComparison.png")
