#### physics #### 

new <- read.csv("Models\\SW_Greenland\\2011-2019\\Driving\\physics_SWG_2011-2019.csv") %>%   # Read in example boundary drivers
  select(SO_IceFree, SI_IceFree, SO_IceCover, SI_IceCover, SO_IceThickness,SO_temp, D_temp, SI_temp, log10Kvert) %>% 
  mutate(Month = 1:12) %>% 
  pivot_longer(!Month, names_to = "Var", values_to = "Value") %>% 
  mutate(Model = "SW Greenland")

comparison <- read.csv("C:\\Users\\psb22188\\AppData\\Local\\R\\win-library\\4.2\\StrathE2EPolar\\extdata\\Models\\Barents_Sea\\2011-2019\\Driving\\physics_BS_2011-2019.csv") %>% 
  select(SO_IceFree, SI_IceFree, SO_IceCover, SI_IceCover, SO_IceThickness,SO_temp, D_temp, SI_temp, log10Kvert) %>% 
  mutate(Month = 1:12) %>% 
  pivot_longer(!Month, names_to = "Var", values_to = "Value") %>% 
  mutate(Model = "Barents Sea") %>% 
  bind_rows(new)

ggplot() +
  geom_line(data = comparison, aes(x = Month, y = Value, colour = Model)) +
  theme_minimal() +
  facet_wrap(vars(Var), scales = "free_y")
