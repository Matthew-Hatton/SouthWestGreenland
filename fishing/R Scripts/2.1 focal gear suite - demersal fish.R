rm(list = ls()) #fresh start
set.seed(710) #make the result reproducible
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
  master <- rbind(master,randdf)
} #build the random dataframe
colnames(master) <- gears
#give ID number
master <- tibble::rowid_to_column(master,"SimulationID") #adds simID
rm(randdf)

#remove bottom rows
master <- master[1:length(scaling),]
#step through chosen gears
master$Demersal_otter_trawl <- master$`Pelagic_trawl+seine`
master$Demersal_seine <- master$`Pelagic_trawl+seine`
master$Longlinesandjiggiing <- master$`Pelagic_trawl+seine`
focalgear <- function(SimulationID,`Pelagic_trawl+seine`,`Demersal_otter_trawl`,`Demersal_seine`,
                      `Gill_nets`,`Longlinesandjiggiing`,`Recreational`,`Shrimp_trawl`,
                      `Creels`,`Mollusc_dredge`,`Harpoons`,`Rifles`,`Kelp_harvester`,focal){
  
  instructions <- c(`Pelagic_trawl+seine`,`Demersal_otter_trawl`,`Demersal_seine`,
                    `Gill_nets`,`Longlinesandjiggiing`,`Recreational`,`Shrimp_trawl`,
                    `Creels`,`Mollusc_dredge`,`Harpoons`,`Rifles`,`Kelp_harvester`)
  model <- e2ep_read("SW_Greenland","2090-2099",
                     models.path = "Models",
                     results.path = "Models/SW_Greenland/2090-2099/Results") #run model
  model[["data"]][["fleet.model"]][["gear_mult"]] <- model[["data"]][["fleet.model"]][["gear_mult"]] * instructions #access gear multipliers and change them
  
  results <- e2ep_run(model,nyears = 50) #run model
  
  #saves outputs
  # saveRDS(results$final.year.outputs$inshore_landmat,str_glue("./fishing/fishing bounds/changingpower/suite experiment/2010-2019/landings/{SimulationID}_inshore.rds"))
  # saveRDS(results$final.year.outputs$inshore_catchmat,str_glue("./fishing/fishing bounds/changingpower/suite experiment/2010-2019/catch/{SimulationID}_inshore.rds"))
  # saveRDS(results$final.year.outputs$inshore_discmat,str_glue("./fishing/fishing bounds/changingpower/suite experiment/2010-2019/discards/{SimulationID}_inshore.rds"))
  # saveRDS(results$final.year.outputs$offshore_landmat,str_glue("./fishing/fishing bounds/changingpower/suite experiment/2010-2019/landings/{SimulationID}_offshore.rds"))
  # saveRDS(results$final.year.outputs$offshore_catchmat,str_glue("./fishing/fishing bounds/changingpower/suite experiment/2010-2019/catch/{SimulationID}_offshore.rds"))
  # saveRDS(results$final.year.outputs$offshore_discmat,str_glue("./fishing/fishing bounds/changingpower/suite experiment/2010-2019/discards/{SimulationID}_offshore.rds"))
  saveRDS(results$final.year.outputs$mass_results_wholedomain,str_glue("./fishing/fishing bounds/changingpower/suite experiment/2090-2099/biomass/{SimulationID}_wholedomain.rds")) #saves biomass
  }

runs <- future_pmap(master,safely(focalgear),.progress = TRUE) #call the function in parallel

toc() #time

