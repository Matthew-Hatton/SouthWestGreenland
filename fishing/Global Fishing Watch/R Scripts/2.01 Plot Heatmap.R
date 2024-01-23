#requires 'extract and summarise change year.R' to be ran first

library(ggthemes)
library(ggplot2)

year <- 2012
Domain <- readRDS("clipped.rds") #load domain polygon
DomainSize <- readRDS("Domains.rds") #load domain sizes
Domain$Shore <- c("Inshore","Offshore") #adds inshore offshore column


all_data <- read.csv(paste0("./fishing/Global Fishing Watch/finished data/",year,"/GFW_",year,".csv")) #read in data


ggplot() +
  geom_sf(data = Domain,fill = "skyblue1",alpha = 0.2) +
  geom_tile(data = all_data,aes(x = cell_ll_lon,y = cell_ll_lat,fill = flag),alpha = 1) +
  #scale_color_gradient(low = "#25DAD9", high = "#DA2526",limits = c(-6,3)) +
  labs(x = "Longitude",y = "Latitude",color = "Fishing Hours",fill = "Gear Type") +
  scale_y_continuous(expand = c(0,0))

# ggplot() +
#   geom_sf(data = Domain,alpha = 0.6) +
#   geom_tile(data = all_data,aes(x = cell_ll_lon,y = cell_ll_lat,fill = geartype),alpha = 0.8,linewidth = 0.2) +
#   scale_color_gradient(low = "#25DAD9", high = "#DA2526") +
#   labs(x = "Longitude",y = "Latitude",color = "Fishing Hours")


#ggsave(paste0("heatmap flag 2012.png"),width = 33.867,height = 19.05,units = "cm",bg = 'white')
