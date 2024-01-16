#This program will extract data from a single year and summarise it. change this file and upload master to github (master is called extract and summarise)
#Important to restart R every run

rm(list=ls()) #reset
library(tidyverse)
library(furrr)
library(sf)
library(dplyr)
plan(multisession)
sf_use_s2(FALSE) #turn off spherical geometry

Domain <- readRDS("clipped.rds") #load domain polygon
DomainSize <- readRDS("Domains.rds") #load domain sizes
Domain$Shore <- c("Inshore","Offshore") #adds inshore offshore column

#specify year
year <- 2012 #remember to change the write csv function year too (doesn't work with this)

#rough crops to region (to reduce file size)
crop <- function(file){
  filter(file,cell_ll_lat < 72.5) %>%
    filter(.,cell_ll_lat > 59) %>%
    filter(.,cell_ll_lon < -45) %>%
    filter(.,cell_ll_lon >-61)
}

files <- list.files(path = paste0("./fishing/Global Fishing Watch/RAW/Daily/",year,"/fleet-daily-csvs-100-v2-",year),
                    full.names = TRUE) #list all year files
all_files <- future_map(files,read.csv,
                        .progress = TRUE) #read in all files from that year

all_files <- lapply(all_files,crop) #crops down those files

all_data <- do.call(rbind.data.frame,all_files) #merges to one dataframe
data_sf <- st_as_sf(all_data,coords = c("cell_ll_lon","cell_ll_lat")) #convert to sf
st_crs(data_sf) <- st_crs(Domain) #match crs
data_sf$Inshore <- st_intersects(data_sf$geometry, Domain$geometry[[1]]) #check if in inshore
data_sf$Offshore <- st_intersects(data_sf$geometry, Domain$geometry[[2]]) #check if in offshore

#reset funky list 0s
data_sf$Inshore[sapply(data_sf$Inshore, length) == 0] <- 0
data_sf$Offshore[sapply(data_sf$Offshore,length) == 0] <- 0

data_sf$domain <- NA #initialise domain checker




#checks which zone
data_sf <- data_sf %>%
  mutate(
    Inshore = as.numeric(Inshore),
    Offshore = as.numeric(Offshore),
    domain = case_when(
      Inshore == 1 ~ "Inshore",
      Offshore == 1 ~ "Offshore",
      TRUE ~ "Outside"
    )
  )
data_sf <- data_sf[!data_sf$domain == "Outside",] #remove outside domain values

aggregate <- data_sf %>%
  group_by(geartype,domain) %>%
  summarise(total_fishing_hours = sum(fishing_hours)/365) #aggregates data (per day)

aggregate_wholedomain <- aggregate #make copy (for plot)

#split
aggregate_in <- aggregate[aggregate$domain == "Inshore",] #filters to Inshore zone
aggregate_in$total_fishing_hours <- (aggregate_in$total_fishing_hours/DomainSize$area[1])*3600 #divides by total area of Inshore zone and mult by seconds in hour

aggregate_off <- aggregate[aggregate$domain == "Offshore",] #filters to Offshore zone
aggregate_off$total_fishing_hours <- (aggregate_in$total_fishing_hours/DomainSize$area[2])*3600 #divides by total area of Offshore zone and mult by seconds in hour

aggregate <- rbind(aggregate_in,aggregate_off) #bind back together


library(tidyverse) #reload library because have to restart session
#the next line requires a restart for some odd reason
aggregate <- dplyr::select(aggregate,c(geartype,domain,total_fishing_hours)) #drop geometry column for write
write.csv(aggregate,"./fishing/Global Fishing Watch/finished data/2012 total fishing hours per day per meter squared in the model domain.csv",row.names = FALSE)

ggplot(data = aggregate_wholedomain) +
  geom_bar(stat = "identity",color = "black",position=position_dodge(),aes(x = geartype,y = log(total_fishing_hours + 1),fill = domain)) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90)) +
  labs(x = "Gear Type",y = paste0("log (Total Fishing Hours per day) - ",year)) +
  NULL

ggsave(paste0("./fishing/Global Fishing Watch/Figures/",year," total fishing hours per day.png"),width = 33.867,height = 19.05,units = "cm",bg = 'white')
