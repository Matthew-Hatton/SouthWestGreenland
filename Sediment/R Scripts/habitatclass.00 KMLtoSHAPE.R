#Produces pretty figure of sediment map

source("@_Region file.R") 

sf_use_s2(FALSE) # turn off spherical geometrey

Domains <- readRDS("Objects\\Domains.RDS") %>%  #read domain file
  st_transform(crs = crs)

Domains$Shore[1] <- "Inshore" #Fix domains typo

habitat <- st_read(dsn = "C:\\Users\\psb22188\\Documents\\PhD\\22-23\\West Greenland\\Sediment\\RAW\\GreenlandHabitatClasses\\GreenlandHabitatClasses.kml") %>% 
  st_transform(crs = crs) #reads in habitat map and converts from kml to shape file. Changes crs


Domains <- st_make_valid(Domains)
habitat <- st_make_valid(habitat) # fixes overlaps


result <- st_intersection(Domains,habitat) #takes intersection and cookie cuts out domain

ggplot() +
  geom_sf(data = Domains,fill = "grey40") +
  geom_sf(data = result,aes(fill = Name)) +
  #geom_sf(data = filter(Domains,Shore == "Inshore"),fill = "snow",alpha = 0.6) +
  #geom_sf(data = Inshore_ocean_boundaries,fill = "firebrick4") + #shows inshore ocean boundaries
  scale_fill_manual(values = c("Muddy Sand" = "blue",
                               "Gravelly Mud" = "green",
                               "Coarse Rocky Ground" = "red",
                               "Mud" = "saddlebrown",
                               "Gravelly Sand" = "orange",
                               "Bedrock with Sand" = "yellow",
                               "Bedrock with Mud" = "coral1"),guide = "legend") +
  labs(fill = "Sediment Class") +
  scale_y_continuous(expand = c(0,0)) +
  scale_x_continuous(expand = c(0,0)) +
  theme(panel.background = element_rect(fill = "grey90")) +
  annotation_scale(location = "bl", width_hint = 0.5) +
  NULL