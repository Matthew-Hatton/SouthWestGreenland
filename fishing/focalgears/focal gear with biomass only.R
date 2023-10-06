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

master <- data.frame()
for (i in 1:length(gears)){
  randdf <- matrix(nrow = length(scaling),ncol = length(gears),data = runif(n = length(scaling)*length(gears),min=scaling[1],
                                                                            max = tail(scaling,n=1))) %>%
    data.frame() #creates dataframe with correct dimensions
  randdf[,i] <- scaling
  randdf$focal <- gears[i]
  master <- rbind(master,randdf)
} #build the random dataframe
colnames(master) <- append(gears,"focal")
#give ID number
master <- tibble::rowid_to_column(master,"SimulationID") #adds simID
rm(randdf)

focalgear <- function(SimulationID,`Pelagic_trawl+seine`,`Demersal_otter_trawl`,`Demersal_seine`,
                      `Gill_nets`,`Longlinesandjiggiing`,`Recreational`,`Shrimp_trawl`,
                      `Creels`,`Mollusc_dredge`,`Harpoons`,`Rifles`,`Kelp_harvester`,focal){
  
  instructions <- c(`Pelagic_trawl+seine`,`Demersal_otter_trawl`,`Demersal_seine`,
                    `Gill_nets`,`Longlinesandjiggiing`,`Recreational`,`Shrimp_trawl`,
                    `Creels`,`Mollusc_dredge`,`Harpoons`,`Rifles`,`Kelp_harvester`)
  model <- e2ep_read("SW_Greenland","2011-2019",
                     models.path = "Models",
                     results.path = "Models/SW_Greenland/2011-2019/Results") #run model
  model[["data"]][["fleet.model"]][["gear_mult"]] <- model[["data"]][["fleet.model"]][["gear_mult"]] * instructions #access gear multipliers and change them
  
  results <- e2ep_run(model,nyears = 50) #run model
  
  #saves outputs
  saveRDS(results$final.year.outputs$mass_results_offshore,str_glue("./fishing/fishing bounds/changingpower/biomassoutputs/offshore/{SimulationID}_offshore_{focal}.rds"))
  saveRDS(results$final.year.outputs$mass_results_inshore,str_glue("./fishing/fishing bounds/changingpower/biomassoutputs/inshore/{SimulationID}_inshore_{focal}.rds"))
  saveRDS(results$final.year.outputs$mass_results_wholedomain,str_glue("./fishing/fishing bounds/changingpower/biomassoutputs/wholedomain/{SimulationID}_wholedomain_{focal}.rds"))
}

runs <- future_pmap(master,safely(focalgear),.progress = TRUE) #call the function in parallel
toc() #time
