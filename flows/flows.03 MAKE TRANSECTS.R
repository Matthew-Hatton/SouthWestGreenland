rm(list=ls())                                                               # Wipe the brain
library(MiMeMo.tools) 
library(furrr)
source("@_Region file.R")                                       # Define project region 

plan(multisession)                                                          # Instruction for parallel processing

domains <- readRDS("Objects/Domains.rds")                                 # Load SF polygons of the MiMeMo model domains

#### Break up polygon ####

Edges <- st_cast(domains, "MULTILINESTRING", group_or_split = TRUE) %>%     # Simplify polygon to mutli-linestrings
  st_cast("LINESTRING", group_or_split = TRUE) %>%                          # Split line into it's own row 
  split(., f = list(.$Shore), ) %>%                                         # Separate out by zone
  future_map(boundaries, crs = crs, .progress = T)                          # Break the linestrings of a domain into transects

ggplot() +                                                                  # Check we're getting the inshore edges correctly
  geom_sf(data = Inshore_ocean_boundaries, colour = "black", fill = "black") +                  
  geom_sf(data = Edges[["Inshore"]], colour = "red") +                  
  geom_sf(data = Edges[["Offshore"]], colour = "yellow") +                  
  theme_minimal() +
  viridis::scale_colour_viridis() +
  theme(legend.position = "none",
        axis.text = element_blank()) +
  labs(caption = paste0("Retain only the inshore transects at the Inshore-Ocean\n
                         boundaries (red, over black). Specify the sampling polygons in the region file")) +
  NULL