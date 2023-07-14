#rm(list=ls())                                                   

Packages <- c("tidyverse", "sf", "stars", "rnaturalearth", "raster","ggspatial")        # List handy packages
lapply(Packages, library, character.only = TRUE)                            # Load packages
setwd("C:\\Users\\psb22188\\Documents\\PhD\\22-23\\West Greenland\\NEMO\\Data Wrangling\\Jacks Way")


source("@_Region file.R")                                       # Define project region 

world <- ne_countries(scale = "medium", returnclass = "sf") %>%             # Get a world map
  st_transform(crs = crs)

GEBCO <- raster("RAW\\GEBCO\\GEBCO_2020.nc")
GFW <- raster("RAW\\GFW\\distance-from-shore.tif")

crop <- as(extent(-61,-45,59,72.5),"SpatialPolygons") #defined as (xmin,xmax,ymin,ymax) <- (W,E,S,N)
crs(crop) <- crs(GEBCO)

GEBCO <- crop(GEBCO, crop)
GFW <- crop(GFW, crop)



Depths <- GEBCO
Depths[Depths >= 0 | Depths < - 600] <- NA #change -1000 to -3500 if doing nice ggplot

Depths[Depths < -50] <- -600 #comment out for nice ggplot
Depths[Depths > -50] <- -50

###ggplot check crop###
# as.data.frame(Depths,xy = TRUE) %>% 
#   ggplot(aes(x = x,y = y, fill = Elevation.relative.to.sea.level)) +
#     geom_raster() +
#     scale_fill_viridis_c(na.value = "white") +
#     labs(fill = "Depth",x = "Longitude",y = "Latitude") +
#     scale_x_continuous(expand = c(0,0)) +
#     scale_y_continuous(expand = c(0,0))


Depths <- st_as_stars(Depths) %>% 
  st_as_sf(merge = TRUE) %>% 
  st_make_valid() %>% 
  group_by(Elevation.relative.to.sea.level) %>% 
  summarise(Depth = abs(mean(Elevation.relative.to.sea.level))) %>% 
  st_make_valid()

Distance <- GFW
Distance[GFW == 0 | GFW > 20] <- NA  # Distance appears to be in KM not m as stated on the website.

Distance[is.finite(Distance)] <- 20  # Distance appears to be in KM not m as stated on the website.

Distance <- st_as_stars(Distance) %>% 
  st_as_sf(merge = TRUE) %>% 
  st_make_valid() %>% 
  group_by(distance.from.shore) %>% 
  summarise(Distance = (mean(distance.from.shore))) %>% 
  st_make_valid()

#makes very nice plot
# ggplot() +
#   geom_sf(data = Depths, aes(fill = Depth), alpha = 0.2) +
#   geom_sf(data = Distance, fill = "red") + 
#   theme_minimal()



##################################################################
meld <- st_union(Distance, filter(Depths, Depth == 50)) %>% 
  st_make_valid()

sf_use_s2(F)

offshore <- filter(Depths, Depth == 600) %>% 
  st_cast("POLYGON") %>% 
  mutate(area = as.numeric(st_area(.))) %>%
  slice_max(order_by = area) 

shrunk <- bind_rows(meld, offshore) %>%
  st_make_valid() %>% 
  st_difference()

# ggplot(shrunk) +
#   geom_sf(aes(fill = Depth), alpha = 0.5) +
#   scale_x_continuous(expand = c(0,0)) +
#   scale_y_continuous(expand = c(0,0)) +
#   theme(legend.position="none")

clipped <- st_intersection(shrunk, st_transform(Region_mask, st_crs(shrunk)))
distanceclip <- st_intersection(clipped,Distance)

# ggplot(clipped) +
#   #geom_sf(data = distanceclip,fill = "red") +
#   geom_sf(aes(fill = Depth), alpha = 0.5) +
#   
#   scale_x_continuous(expand = c(0,0)) +
#   scale_y_continuous(expand = c(0,0)) +
#   theme(legend.position="none") +
#   annotation_scale(location = "bl", width_hint = 0.5)
#ggsave(filename = "MapOfWG 600m contour.pdf")

GEBCO[GEBCO < - 500] <- -500                     # Use the overhang depth to correctly calculate elevation 

Domains <- transmute(clipped, 
                     Shore = ifelse(Depth == 40, "Inshore", "Offshore"),
                     area = as.numeric(st_area(shrunk)),
                     Elevation = exactextractr::exact_extract(GEBCO, shrunk, "mean")) %>% 
  st_transform(crs = crs)

saveRDS(Domains, "./Objects/Domains.rds")

#plot(GEBCO)
