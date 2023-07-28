### produces map with dark grey outline showing inshore zone with sediment map overlayed so we can see
### how much of sediment map is in the offshore zone

source("..\\@_Region file.R") 

Domains <- readRDS("Domains.RDS") %>%  #read domain file
  st_transform(crs = 4326)

Domains$Shore[1] <- "Inshore" #Fix domains typo

habitat <- st_read(dsn = "C:\\Users\\psb22188\\Documents\\PhD\\22-23\\West Greenland\\Sediment\\RAW\\GreenlandHabitatClasses\\GreenlandHabitatClasses.kml") %>% 
  st_transform(crs = 4326) #reads in habitat map and converts from kml to shape file. Changes crs

habitat <- st_make_valid(habitat) # fixes overlaps
Domains <- st_make_valid(Domains)
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
  theme(panel.background = element_rect(fill = "snow")) +
  NULL
#ggsave(filename = "..\\Sediment map 4326.pdf")
