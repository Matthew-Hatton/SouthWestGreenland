#Visualise NEMO output

#### Set Up ####

rm(list = ls(all.names = TRUE))

library(MiMeMo.tools)
library(furrr)
plan(multisession)

TS <- readRDS("Objects/TS.rds") #read in TS
vars_ts <- c("Ice_pres", "Ice_conc_avg", "Ice_Thickness_avg", "Snow_Thickness_avg", 
             "Salinity_avg", "Temperature_avg", "DIN_avg", "Detritus_avg", "Phytoplankton_avg") # List of variables to plot   

SP <- readRDS("Objects/SPATIAL.rds")
vars_sp <- str_remove(vars_ts,"_avg") %>% 
  c("Speed")  #tweak var names for spatial plots


#### Plotting ####

walk(vars_ts,ts_plot) #save ts figure for each var

future_map2(rep(SP,each = length(vars_sp)), #... for each decade
            rep(vars_sp,times = length(SP)),point_plot,#... and each variable
            .progress = TRUE)               #plot currents in parallel