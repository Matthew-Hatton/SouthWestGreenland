#Find what proportions of the habitat classes are in the inshore/offshore zones
rm(list = ls()) #could all do with a fresh start

source("@_Region file.R") 

sf_use_s2(FALSE) # turn off spherical geometrey

Domains <- readRDS("Objects\\Domains.RDS") %>%  #read domain file
  st_transform(crs = crs)

Domains$Shore[1] <- "Inshore" #Fix domains typo

habitat <- st_read(dsn = "C:\\Users\\psb22188\\Documents\\PhD\\22-23\\West Greenland\\Sediment\\RAW\\GreenlandHabitatClasses\\GreenlandHabitatClasses.kml") %>% 
  st_transform(crs = crs) #reads in habitat map and converts from kml to shape file. Changes crs



Domains <- st_make_valid(Domains)
habitat <- st_make_valid(habitat) # fixes overlaps


result <- st_intersection(Domains,habitat) %>%  #takes intersection and cookie cuts out domain
  subset(select = -c(area))

#total area of the entire domain
total_domain_area <- sum(st_area(result$geometry))

#calculate area of each sediment type in both inshore and offshore zones
sediment_areas <- result %>%
  group_by(Name, Shore) %>%
  summarize(area = sum(st_area(geometry))) %>%
  ungroup() %>% 
  mutate(proportion = area / total_domain_area) #calculate proportion of sed type wrt total domain area

print(sum(sediment_areas$proportion)) #check to see if they add to 1

saveRDS(sediment_areas,"Objects\\Sediment Proportions.RDS")

