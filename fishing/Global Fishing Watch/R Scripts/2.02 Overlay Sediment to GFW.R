library(rnaturalearth)
library(ggplot2)
library(sf)
source("@_Region file.R") 

all_data <- read.csv(paste0("./fishing/Global Fishing Watch/finished data/",year,"/GFW_",year,".csv")) #read in data
Domain <- readRDS("clipped.rds") #load domain polygon
DomainSize <- readRDS("Domains.rds") #load domain sizes
habitat <- st_read(dsn = "C:\\Users\\psb22188\\Documents\\PhD\\22-23\\West Greenland\\Sediment\\RAW\\GreenlandHabitatClasses\\GreenlandHabitatClasses.kml") %>% 
  st_transform(crs = st_crs(data_sf))
habitat$Name <- c("Rock",#bedrock with mud
                     "Sand",#muddy sand
                     "Gravel",#Gravelly Mud
                     "Gravel",#coarse rocky ground
                     "Mud",#Mud
                     "Sand",#Gravelly sand
                     "Rock")#Bedrock with Sand

st_crs(DomainSize) <- st_crs(habitat)
focal_gear <- filter(all_data,geartype == "other_purse_seines")
result <- st_intersection(Domain,habitat) #takes intersection and cookie cuts out domain

ggplot(result) +
  geom_sf(aes(fill = Name),alpha = 0.8) +
  geom_sf(data = Domain,aes(fill = Shore),alpha = 0.1) +
  #geom_sf(data = basemap,fill = "white",alpha = 1) +
  geom_tile(data = all_data,aes(x = cell_ll_lon,y = cell_ll_lat),linewidth = 0.1,color = "#081a24",alpha = 0.3) +
  #scale_color_gradient(low = "#25DAD9", high = "#DA2526",limits = c(-6,3)) +
  labs(x = "Longitude",y = "Latitude",color = "Fishing Hours",fill = "Sediment Type") +
  scale_y_continuous(expand = c(0,0)) +
  scale_fill_manual(values = c("Rock" = "#5B7C99",
                               "Gravel" = "#7D7D7D",
                               "Sand" = "#E2C085",
                               "Mud" = "#8B4513",
                               guide = "legend")) +
  scale_x_continuous(expand = c(0,0)) +
  ggtitle(paste0(year)) +
  NULL

ggsave(paste0("./fishing/Global Fishing Watch/Figures/Daily/2012/heatmap sediment 2012.png"),width = 33.867,height = 19.05,units = "cm",bg = 'white')
