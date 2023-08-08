Physical_parameters <- read.csv("Models\\SW_Greenland\\2011-2019\\Param\\physical_parameters_BS.csv")
OffshoreSed <- readRDS("Objects\\Offshore sediment proportions.rds")
InshoreSed <- readRDS("Objects\\Inshore sediment proportions.rds")

## layer thickness ##
My_space <- readRDS("Objects/Domains.rds") %>%                            # Calculate the volume of the three zones
  sf::st_drop_geometry() %>% 
  mutate(S = c(T, T),
         D = c(F, T)) %>% 
  gather(key = "Depth", value = "Exists", S, D) %>% 
  filter(Exists == T) %>%
  mutate(Elevation = c(Elevation[1], -40, Elevation[3] + 40)) %>% 
  mutate(Volume = area * abs(Elevation))

Physical_parameters[1,"Value"] <- filter(My_space, Shore == "Offshore", Depth == "S")$Elevation * -1 # Offshore_Shallow_layer_thickness_(m)
Physical_parameters[2,"Value"] <- filter(My_space, Shore == "Offshore", Depth == "D")$Elevation * -1 # Offshore_Deep_layer_thickness_(m)
Physical_parameters[3,"Value"] <- filter(My_space, Shore == "Inshore", Depth == "S")$Elevation * -1  # Inshore_Shallow_layer_thickness_(m)

## Update sediment ##

Physical_parameters[5,1] <- InshoreSed[1,2] #inshore rock
Physical_parameters[6,1] <- InshoreSed[2,2] #inshore mud
Physical_parameters[7,1] <- InshoreSed[3,2] #inshore sand
Physical_parameters[8,1] <- InshoreSed[4,2] #inshore gravel

Physical_parameters[9,1] <- OffshoreSed[1,2] #inshore rock
Physical_parameters[10,1] <- OffshoreSed[2,2] #inshore mud
Physical_parameters[11,1] <- OffshoreSed[3,2] #inshore sand
Physical_parameters[12,1] <- OffshoreSed[4,2] #inshore gravel

## Update median grain size ##

Physical_parameters[13,1] <- InshoreSed[2,3]
Physical_parameters[14,1] <- InshoreSed[3,3]
Physical_parameters[15,1] <- InshoreSed[4,3]
Physical_parameters[16,1] <- InshoreSed[2,3]
Physical_parameters[17,1] <- InshoreSed[3,3]
Physical_parameters[18,1] <- InshoreSed[4,3]

Physical_parameters[20,"Value"] <- -1.035                  # Parameter_1_for_relationship_between_porosity_and_grainsize. Values from Matt Pace's thesis
Physical_parameters[21,"Value"] <- -0.314                  # Parameter_2_for_relationship_between_porosity_and_grainsize. The values are also the defaults in the D50_to_porosity function
Physical_parameters[22,"Value"] <- -0.435                  # Parameter_3_for_relationship_between_porosity_and_grainsize
Physical_parameters[23,"Value"] <- 0.302                   # Parameter_4_for_relationship_between_porosity_and_grainsize

#writes file
write.csv(Physical_parameters, file = "Models\\SW_Greenland\\2011-2019\\Param\\physical_parameters_SWG.csv", row.names = F)