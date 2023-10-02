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
for (i in 1:length(gears)){ #shouldn't be using a for loop here
  randdf <- matrix(nrow = length(scaling),ncol = length(gears),data = runif(n = length(scaling)*length(gears),min=scaling[1],
                                                                            max = tail(scaling,n=1))) %>%
    data.frame() #creates dataframe with correct dimensions
  randdf[,i] <- scaling
  randdf$focal <- gears[i]
  master <- rbind(master,randdf)
}
colnames(master) <- append(gears,"focal")
#give ID number
master <- tibble::rowid_to_column(master,"SimulationID")
rm(randdf)

#row_list <- split(master, seq(nrow(master))) #split each df row into list

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
  saveRDS(results$final.year.outputs$inshore_landmat,str_glue("./fishing/fishing bounds/changingpower/output3/landings/{SimulationID}_inshore_{focal}.rds"))
  saveRDS(results$final.year.outputs$inshore_catchmat,str_glue("./fishing/fishing bounds/changingpower/output3/catch/{SimulationID}_inshore_{focal}.rds"))
  saveRDS(results$final.year.outputs$inshore_discmat,str_glue("./fishing/fishing bounds/changingpower/output3/discards/{SimulationID}_inshore_{focal}.rds"))
  saveRDS(results$final.year.outputs$offshore_landmat,str_glue("./fishing/fishing bounds/changingpower/output3/landings/{SimulationID}_offshore_{focal}.rds"))
  saveRDS(results$final.year.outputs$offshore_catchmat,str_glue("./fishing/fishing bounds/changingpower/output3/catch/{SimulationID}_offshore_{focal}.rds"))
  saveRDS(results$final.year.outputs$offshore_discmat,str_glue("./fishing/fishing bounds/changingpower/output3/discards/{SimulationID}_offshore_{focal}.rds"))
}

#apply scaling vector n - parallel
runs <- future_pmap(master,safely(focalgear),.progress = TRUE)
toc() #time

