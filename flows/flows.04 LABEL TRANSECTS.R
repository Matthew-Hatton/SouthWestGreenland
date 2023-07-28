#### Set up ####

rm(list=ls())                                                               # Wipe the brain
library(MiMeMo.tools)
source("@_Region file.R")                                       # Define project region 

domains <- readRDS("Objects\\Domains.rds")                                 # Load SF polygons of the MiMeMo model domains

Edges <- readRDS("Objects\\Split_boundary.rds") %>%                        # Load in segments of domain boundaries
  mutate(Segment = as.numeric(Segment))

points <- readRDS("Objects/Months/NM.01.1980.rds") %>%                     # Import an NM summary object
  filter(slab_layer == "S") %>%                                             # Limit to the shallow layer to avoid duplication (and it's bigger)
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326) %>%             # Set as sf object
  st_transform(crs = crs)

grid <- st_union(points) %>%                                                # Combine              
  st_voronoi() %>%                                                          # And create a voronoi tesselation
  st_collection_extract(type = "POLYGON") %>%                               # Expose the polygons
  sf::st_sf() %>%                                                           # Reinstate sf formatting
  st_join(points) %>%                                                       # Rejoin meta-data from points
  arrange(x, y)                                                             # Order the polygons to match the points

ggplot(grid) +                                                              # Check the polygons match correctly with points
  geom_sf(aes(fill = Ice_conc), size = 0.05, colour = "white") +
  geom_sf(data = Edges, colour = "orange") +
  xlim(-811836.8,-284011.9) + #crop in
  ylim(-3357041,-1822647) +
  theme_minimal() +
  labs(caption = "If the spatial pattern looks right, polygons and points are matched") +
  NULL
ggsave("check.png")

labelled <- st_intersection(Edges, grid) %>% 
  mutate(split_length = as.numeric(st_length(.))) %>% 
  select(x, y, slab_layer, Shore, split_length, Bathymetry) %>% 
  characterise_flows(domains) %>%                                               # In which direction? (in or out of box and with which neighbour)
  filter(Neighbour != "Offshore")                                               # Offshore as a neighbour is a rare artefact from resolution.

##### NEIGHBOUR THING DOESN'T WORK - WILL LOOK ON TUESDAY 01/08/23 AFTER HOLIDAY


ggplot(labelled) +                                                              # Check segments are labelled
  geom_sf(aes(colour = Neighbour)) +
  viridis::scale_colour_viridis(option = "viridis", na.value = "red", discrete = T) +
  zoom +
  labs(caption = "Check the transects are correctly labelled by zone") +
  theme_minimal()