#summarise data extracted from NEMO, dealing with deep convection issues

rm(list = ls())#fresh start

Packages <- c("tidyverse","data.table","furrr")
lapply(Packages,library,character.only = TRUE)

plan(multisession)

deep_convection_is <- 0.14 #threshold above which vert diff = deep convection

#### quantify deep convection ####

total_mixing <- list.files("Objects/vertical boundary/",full.names = TRUE) %>% #import
  future_map(readRDS) %>% 
  rbindlist() %>% 
  group_by(Month) %>% 
  summarise(Deep_convection_proportion = mean(Vertical_diffusivity > deep_convection_is)) #what proportion of values are deep convection?

ggplot(total_mixing) +
  geom_line(aes(x = Month,y = Deep_convection_proportion)) +
  theme_minimal() +
  ylim(0,1) +
  labs(y = "Proportion of model domain as deep convection")

normal_mixing <- list.files("Objects/vertical boundary/", full.names = T) %>% # Import data
  future_map(readRDS) %>% 
  rbindlist() %>% 
  dplyr::select(Vertical_diffusivity, Year, Month) %>%                                 # Discard excess variables
  filter(Vertical_diffusivity < deep_convection_is) %>%                         # Remove deep convection
  group_by(Year, Month) %>%                                                     # Create a monthly time series
  summarise(Vertical_diffusivity = mean(Vertical_diffusivity, na.rm = T)) %>% 
  ungroup()

saveRDS(normal_mixing, "Objects/vertical diffusivity.rds")
