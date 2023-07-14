#Pull time series from NEMO data

#### Set Up ####

rm(list = ls())

library(MiMeMo.tools)
library(furrr)
plan(multisession)

#### Extract Time Series ####

tic("Creating time series by compartment") #time the data extraction

TS <- list.files("Objects/Months",full.names = T) %>% #get list of NEMO files
  future_map(NM_volume_summary,
             ice_threshold = 0.15,
             .progress = T) %>% #treating pixels with ice concentrations below 15% as ice free
  data.table::rbindlist() %>% #combine timesteps into series
  mutate(date = as.Date(paste("15",Month,Year,sep = "/"),format = "%d/%m/%Y"),#create single data column for plotting
         Compartment = paste(Shore,slab_layer,sep = " ")) %>% #build single compartment column for plotting by
  filter(Compartment != "Inshore D") %>% #non-existant combination gets introduced when extracting data because the GEBCO and NM bathys differ
saveRDS("Objects/TS.rds")#save out TS in folder
toc()#stop timing