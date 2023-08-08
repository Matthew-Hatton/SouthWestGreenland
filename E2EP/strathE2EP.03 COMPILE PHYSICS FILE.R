
## Overwrite example driving data (boundaries and physics)

#### Setup ####

rm(list=ls())                                                               # Wipe the brain

library(MiMeMo.tools)

Physics_template <- read.csv("Models\\SW_Greenland\\2011-2019\\Driving\\physics_BS_2011-2019.csv") # Read in example Physical drivers
Depths <- read.csv("Models\\SW_Greenland\\2011-2019\\Param\\physical_parameters_BS.csv", nrows = 3)# Import Mike's original depths for scaling

My_scale <- readRDS("Objects/Domains.rds") %>%                            # Calculate the volume of the three zones
  sf::st_drop_geometry() %>% 
  mutate(S = c(T, T),
         D = c(F, T)) %>% 
  gather(key = "slab_layer", value = "Exists", S, D) %>% 
  filter(Exists == T) %>%
  mutate(Elevation = c(Depths[3,1], Depths[1,1], Depths[2,1])) %>%          # Pulls Mike's original depths instead of GEBCO 
  mutate(Volume = area * abs(Elevation)) %>% 
  dplyr::select(Shore, slab_layer, Volume)

My_V_Flows <- readRDS("Objects/vertical diffusivity.rds") #read in vert diffusivities
My_V_Flows$Year <- My_V_Flows$Year + 2000 #fix year starting at 0 (will fix in master file eventually not as of 03/08/23)

My_V_Flows <- filter(My_V_Flows,between(Year, 2011, 2019)) %>%                                     # Limit to reference period
  group_by(Month) %>% 
  summarise(V_diff = mean(Vertical_diffusivity, na.rm = T)) %>% 
  ungroup()

My_volumes <- readRDS("Objects/TS.rds") %>% 
  filter(between(Year, 2011, 2019)) %>%                                     # Limit to reference period
  group_by(Compartment, Month) %>%                                          # By compartment and month
  summarise(across(Salinity_avg:Ice_conc_avg, mean, na.rm = T)) %>%         # Average across years for multiple columns
  ungroup() %>% 
  arrange(Month)                                                            # Order by month to match template

#### Create new file ####

Physics_new <- mutate(Physics_template, ## Flows, should be proportions of volume per day #not finished flows yet!
                      # SO_OceanIN = filter(My_H_Flows, slab_layer == "S", Shore == "Offshore", Neighbour == "Ocean", Direction == "In")$Flow,
                      # D_OceanIN = filter(My_H_Flows, slab_layer == "D", Shore == "Offshore", Neighbour == "Ocean", Direction == "In")$Flow,
                      # SI_OceanIN = filter(My_H_Flows, slab_layer == "S", Shore == "Inshore", Neighbour == "Ocean", Direction == "In")$Flow,
                      # SI_OceanOUT = filter(My_H_Flows, slab_layer == "S", Shore == "Inshore", Neighbour == "Ocean", Direction == "Out")$Flow,
                      # SO_SI_flow = filter(My_H_Flows, slab_layer == "S", Shore == "Offshore", Neighbour == "Inshore", Direction == "Out")$Flow,
                      ## Temperatures in volumes for each zone
                      SO_temp = filter(My_volumes, Compartment == "Offshore S")$Temperature_avg,
                      D_temp = filter(My_volumes, Compartment == "Offshore D")$Temperature_avg,
                      SI_temp = filter(My_volumes, Compartment == "Inshore S")$Temperature_avg ,
                      ## Vertical diffusivity
                      log10Kvert = log10(My_V_Flows$V_diff),
                      #Ice vars
                      SO_IceFree = 1 - filter(My_volumes, Compartment == "Offshore S")$Ice_pres,
                      SI_IceFree = 1 - filter(My_volumes, Compartment == "Inshore S")$Ice_pres,
                      SO_IceCover = filter(My_volumes, Compartment == "Offshore S")$Ice_conc_avg,
                      SI_IceCover = filter(My_volumes, Compartment == "Inshore S")$Ice_conc_avg,
                      SO_IceThickness = filter(My_volumes, Compartment == "Offshore S")$Ice_Thickness_avg, 
                      SI_IceThickness = filter(My_volumes, Compartment == "Inshore S")$Ice_Thickness_avg,
                      SO_SnowThickness = filter(My_volumes, Compartment == "Offshore S")$Snow_Thickness_avg, 
                      SI_SnowThickness = filter(My_volumes, Compartment == "Inshore S")$Snow_Thickness_avg) %>% 
  mutate(log10Kvert = ifelse(log10Kvert == -Inf, 0, log10Kvert))

write.csv(Physics_new, file = "Models\\SW_Greenland\\2011-2019\\Driving\\physics_SWG_2011-2019.csv", row.names = F)


sed <- read.csv("Models\\SW_Greenland\\2011-2019\\Param\\physical_parameters_BS.csv")
OffshoreSed <- readRDS("Objects\\Offshore sediment proportions.rds")
InshoreSed <- readRDS("Objects\\Inshore sediment proportions.rds")

## Update sediment (probably better way to do this) ##

sed[5,1] <- InshoreSed[1,2] #inshore rock
sed[6,1] <- InshoreSed[2,2] #inshore mud
sed[7,1] <- InshoreSed[3,2] #inshore sand
sed[8,1] <- InshoreSed[4,2] #inshore gravel

sed[9,1] <- OffshoreSed[1,2] #inshore rock
sed[10,1] <- OffshoreSed[2,2] #inshore mud
sed[11,1] <- OffshoreSed[3,2] #inshore sand
sed[12,1] <- OffshoreSed[4,2] #inshore gravel

## Update median grain size ##

sed[13,1] <- InshoreSed[2,3]
sed[14,1] <- InshoreSed[3,3]
sed[15,1] <- InshoreSed[4,3]
sed[16,1] <- InshoreSed[2,3]
sed[17,1] <- InshoreSed[3,3]
sed[18,1] <- InshoreSed[4,3]

#writes file twice, could go back and change but 6 and half a dozen
write.csv(sed, file = "Models\\SW_Greenland\\2011-2019\\Param\\physical_parameters_SWG.csv", row.names = F)
