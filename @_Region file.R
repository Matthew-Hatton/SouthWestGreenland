## Set repeated commands specific to the project region
## This version is parameterised for the Barents sea

library(sf,ggplot2)

crs <- 3574                                                              # Specify the map projection for the project

lims <- c(xmin = 500000, xmax = 614893, ymin = 6540052, ymax = 8044704)# Specify limits of plotting window, also used to clip data grids

zoom <- coord_sf(xlim = c(lims[["xmin"]], lims[["xmax"]]), ylim = c(lims[["ymin"]], lims[["ymax"]])) # Specify the plotting window for SF maps in this region

ggsave_map <- function(filename, plot) {
  ggsave(filename, plot, scale = 1, width = 12, height = 10, units = "cm", dpi = 500)
  
}                             # Set a new default for saving maps in the correct size

pre <- list(scale = 1, width = 12, height = 10, units = "cm", dpi = 500) # The same settings if you need to pass them to a function in MiMeMo.tools

#### bathymetry.5 MODEL DOMAIN ####

shape <- function(matrix) {
  
  shape <-  matrix %>% 
    list() %>% 
    st_polygon() %>% 
    st_sfc() %>% 
    st_sf(Region = "Southwest Greenland",.)
  st_crs(shape) <- st_crs(4326)                                        
  shape <- st_transform(shape, crs = crs)
  return(shape)
  
}                      # Convert a matrix of lat-lons to an sf polygon

Region_mask <- matrix(c(-45, 59,
                        -61, 59,
                        -61,66,
                        -60,66,
                        -60,67,
                        -61,67,
                        -61, 72.5,
                        -45, 72.5,
                        -45, 59),
                      ncol = 2, byrow = T) %>% 
  list() %>% 
  st_polygon() %>% 
  st_sfc() %>% 
  st_sf(Region = "Southwest Greenland",.)
st_crs(Region_mask) <- st_crs(4326)                                        
Region_mask <- st_transform(Region_mask, crs = crs)

#### bounds.2 MAKE TRANSECTS ####

## Polygons to mark which transects are along the open ocean-inshore boundary

northinshore <- matrix(c(-56.7, -55.65, -55.65, -56.7, -56.7,    # Longitudes
                           72.45, 72.45, 72.55, 72.55, 72.45), # Latitudes
                         ncol = 2, byrow = F) %>%
  shape()


southinshore <- matrix(c(-45.1, -44.9, -44.9, -45.1, -45.1,               # Longitudes
                           59.7, 59.7, 60, 60, 59.7), # Latitudes
                         ncol = 2, byrow = F) %>%
  shape()
# 
# Inshore_Ocean3 <- matrix(c(-5, -5.55, -5.55, -5, -5,             # Longitudes
#                            52, 52, 51.8, 51.8, 52), ncol = 2, byrow = F) %>% 
#   shape()
# 
# Inshore_Ocean4 <- matrix(c(-4.7, -4.75, -4.75, -4.7, -4.7,             # Longitudes
#                            50.4, 50.4, 50.2, 50.2, 50.4), ncol = 2, byrow = F) %>% 
#   shape()
# 
Inshore_ocean_boundaries <- rbind(northinshore, southinshore)
# 
rm(northinshore,southinshore)

# #### expand polygon for sampling rivers ####
# 
# river_expansion <- matrix(c(13, 73,
#                             0, 80,
#                             0, 85,
#                             63, 85,
#                             73, 77,
#                             30, 71,
#                             13, 73),
#                           ncol = 2, byrow = T) %>% 
#   list() %>% 
#   st_polygon() %>% 
#   st_sfc() %>% 
#   st_sf(Region = "Southwest Greenland",.)
# st_crs(river_expansion) <- st_crs(4326)                                          
# river_expansion <- st_transform(river_expansion, crs = 2303)