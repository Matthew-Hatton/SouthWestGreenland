Packages <- c("tidyverse","sf","data.table","furrr","raster") #list the packages
lapply(Packages,library,character.only = TRUE) #load the packages

plan(multisession) #parallel processing

domain <- readRDS("Objects/Domains.rds") #loads domain file

file <- list.files("I:\\Science\\MS\\Shared\\CAO\\nemo\\ALLARC\\1980",
                   recursive = T,full.names = TRUE,pattern = "grid_W")[1] #access example NEMO file

domain <- st_transform(domain,4326) #transform domain back to latlon

sf_use_s2(FALSE) #turn off spherical geometry (fixes NM_space)

NM_space <- raster(file,varname = "nav_lat") %>% #rasterise example grid_W
  as.data.frame(xy = TRUE) %>% 
  cbind(Lon = as.data.frame(raster(file,varname = "nav_lon"))) %>% 
  setNames(c("x","y","latitude","longitude")) %>% 
  st_as_sf(coords = c("longitude","latitude"),crs = 4326) %>% 
  st_join(domain) %>% 
  drop_na() %>% 
  st_drop_geometry %>% 
  dplyr::select(x,y)

setDT(NM_space,key = c("x","y"))

NM <- list.files("I:\\Science\\MS\\Shared\\CAO\\nemo\\ALLARC",
                 recursive = T,full.names = TRUE,pattern = "grid_W") %>% 
  .[. %like% "2004"] %>% 
  future_map(~{
    file <- raster::raster(.x,band = 9,varname = "votkeavt") %>%  #rasters vertical eddy diffusivity
      as.data.frame(na.rm = T, xy = T)
    
    setDT(file, key = c("x", "y"))
    file <- file[NM_space]
    gc()
    return(file)}) %>% 
  rbindlist() %>% 
  setNames(c("x", "y", "vertical_diffusivity"))

setDT(NM, key = c("x", "y"))

NM <- NM[vertical_diffusivity != 0]                               # Drop NAs (points beneath the seafloor get 0)

a <- ggplot() +
  geom_density(data = NM, aes(vertical_diffusivity), fill = "orange", size = 0.2) +
  #  geom_density(data = SINMOD, aes(vertical_diffusivity), fill = "blue", size = 0.2) +
  geom_density(data = NM, aes(vertical_diffusivity), fill = "orange", alpha = 0.6, size = 0.2) +
  #  geom_density(data = SINMOD, aes(vertical_diffusivity), size = 0.2) +
  ggtext::geom_richtext(aes(x = 2, y = 25), fill = NA, label.color = NA, label.padding = grid::unit(rep(0, 4), "pt"),
                        hjust = 0, vjust = 1, size = 4, 
                        label = str_glue("<b style = 'color:orange'>NEMO-MEDUSA:</b> 
               mean = {round(mean(NM$vertical_diffusivity, na.rm = T), 3)}<br>
               <b style = 'color:blue'>SINMOD:</b> mean = SKIPPED")) +
  theme_minimal() +
  theme(plot.caption = ggtext::element_markdown()) +
  labs(caption = "Density distribution of vertical diffusivity values for
       <b style = 'color:orange'>NEMO-MEDUSA</b> and <b style = 'color:blue'>SINMOD</i></b>
       model outputs at 10m",
       x= "Vertical diffusivity") +
  NULL

saveRDS(a, "Cache/domain_V_a.rds")

rm(NM)


## Vertical ##
Vert <- list.files("I:\\Science\\MS\\Shared\\CAO\\nemo\\ALLARC",
                   recursive = T,full.names = TRUE,pattern = "grid_W") %>% 
  .[. %like% "1980"] %>% 
  .[c(T,F)] %>% #drop every other element
  future_map2(str_sub(., start = -11, end = -6), 
              ~{
                data <- raster::brick(.x, varname = "votkeavt") %>% 
                  as.data.frame(xy = T) %>% 
                  pivot_longer(-c(x,y), names_to = "Depth", values_to = "Diffusivity") %>% 
                  mutate(Depth = as.numeric(str_remove(Depth, "X")),
                         timestep = .y)
                
                setDT(data, key = c("x", "y"))
                
                data <- data[NM_space]
              }, .progress = TRUE) %>% 
  rbindlist()
  
Convection_avg <- Vert[Diffusivity != 0, .(Deep = mean(Diffusivity > 0.14), Area = .N), by = .(Depth, timestep)] %>% 
  mutate(month = as.numeric(str_sub(timestep, -2,-1))) %>% 
  group_by(month, Depth) %>% 
  summarise(Area = mean(Area),
            Deep = mean(Deep)) %>% 
  ungroup() %>% 
  mutate(Q = case_when(between(month, 1,3) ~ "Q1",
                       between(month, 4,6) ~ "Q2",
                       between(month, 7,9) ~ "Q3",
                       between(month, 10,12) ~ "Q4"))
b <- ggplot(Convection_avg) + 
  geom_area(data = filter(Convection_avg, month== 1), aes(x = Depth, y = Area/max(Area)), fill = "grey")  +
  geom_vline(aes(xintercept = 40), colour = "white", size = 2)  +
  geom_line(aes(x = Depth, y = Deep, group = month, colour = Q))  +
  geom_label(aes(label = "Horizontal area", x = 325, y = 0.8), fill = "grey", colour = "white", fontface = "bold") +
  theme_minimal() +
  theme(legend.position = "top") +
  scale_colour_manual(values = c("blue", "lightgreen", "Red", "darkorange")) +
  labs(y = "Proportion of area subject to deep convection",
       x = "Depth (m)", colour = "Quarter") + 
  coord_flip() +
  xlim(400, 0) +
  NULL  

#saveRDS(b, "Cache/domain_V_b.rds")


Diffusivity_avg <- Vert[Diffusivity != 0 & Diffusivity < 0.14, .(Diffusivity = mean(Diffusivity), Area = .N), by = .(Depth, timestep)] %>% 
  mutate(month = as.numeric(str_sub(timestep, -2,-1))) %>% 
  group_by(month, Depth) %>% 
  summarise(Area = mean(Area),
            Diffusivity = mean(Diffusivity)) %>% 
  ungroup() %>% 
  mutate(Q = case_when(between(month, 1,3) ~ "Q1",
                       between(month, 4,6) ~ "Q2",
                       between(month, 7,9) ~ "Q3",
                       between(month, 10,12) ~ "Q4"))

c <- ggplot(Diffusivity_avg) + 
  geom_area(data = filter(Diffusivity_avg, month== 1), aes(x = Depth, y = Area/max(Area)*max(Diffusivity)), fill = "grey")  +
  geom_vline(aes(xintercept = 40), colour = "white", size = 2)  +
  geom_line(aes(x = Depth, y = Diffusivity, group = month, colour = Q))  +
  geom_label(aes(label = "Horizontal area", x = 325, y = 0.02), fill = "grey", colour = "white", fontface = "bold") +
  theme_minimal() +
  theme(legend.position = "top") +
  scale_colour_manual(values = c("blue", "lightgreen", "Red", "darkorange")) +
  labs(y = "Vertical diffusivity (ignoring deep convection)",
       x = "Depth (m)", colour = "Quarter") + 
  coord_flip() +
  xlim(400, 0) +
  NULL

saveRDS(c, "Cache/domain_V_c.rds")
