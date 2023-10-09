rm(list = ls()) #fresh start
library(tidyverse)
library(StrathE2EPolar)
library(furrr)
library(tictoc)

tic() #time
plan("multisession")

#define scaling vectors
scaling <- seq(0,4,0.01)
gears <- c("Pelagic_trawl+seine",
           "Demersal_otter_trawl",
           "Demersal_seine",
           "Gill_nets",
           "Longlinesandjiggiing",
           "Recreational",
           "Shrimp_trawl",
           "Creels",
           "Mollusc_dredge",
           "Harpoons",
           "Rifles",
           "Kelp_harvester"
)
master <- read.csv("./fishing/fishing bounds/changingpower/mastercombinationsdf.csv") %>% #loads in master df
  .[,-1] #use same master dataframe as other simulation
focalgear <- function(SimulationID,`Pelagic_trawl.seine`,`Demersal_otter_trawl`,`Demersal_seine`,
                      `Gill_nets`,`Longlinesandjiggiing`,`Recreational`,`Shrimp_trawl`,
                      `Creels`,`Mollusc_dredge`,`Harpoons`,`Rifles`,`Kelp_harvester`,focal){
  
  instructions <- c(`Pelagic_trawl.seine`,`Demersal_otter_trawl`,`Demersal_seine`,
                    `Gill_nets`,`Longlinesandjiggiing`,`Recreational`,`Shrimp_trawl`,
                    `Creels`,`Mollusc_dredge`,`Harpoons`,`Rifles`,`Kelp_harvester`)
  model <- e2ep_read("SW_Greenland","2011-2019",
                     models.path = "Models",
                     results.path = "Models/SW_Greenland/2011-2019/Results") #run model
  model[["data"]][["fleet.model"]][["gear_mult"]] <- model[["data"]][["fleet.model"]][["gear_mult"]] * instructions #access gear multipliers and change them
  
  results <- e2ep_run(model,nyears = 50) #run model
  
  #saves outputs
  saveRDS(results$final.year.outputs$mass_results_offshore,str_glue("./fishing/fishing bounds/changingpower/biomassoutputs/inoff/{SimulationID}_offshore_{focal}.rds"))
  saveRDS(results$final.year.outputs$mass_results_inshore,str_glue("./fishing/fishing bounds/changingpower/biomassoutputs/inoff/{SimulationID}_inshore_{focal}.rds"))
  saveRDS(results$final.year.outputs$mass_results_wholedomain,str_glue("./fishing/fishing bounds/changingpower/biomassoutputs/wholedomain/{SimulationID}_wholedomain_{focal}.rds"))
}

runs <- future_pmap(master,safely(focalgear),.progress = TRUE) #call the function in parallel
saveRDS(runs,file = "runfails.Rds")
toc() #time
