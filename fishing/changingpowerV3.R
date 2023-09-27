rm(list = ls()) #fresh start
library(tidyverse)
library(StrathE2EPolar)
library(furrr)
library(tictoc)

tic() #time
plan("multisession")

#define scaling vectors
scaling <- seq(0,4,0.005)
gears <- c("Pelagic_trawl+seine",
           "Demersal_otter_trawl",
           "Demersal_seine",
           "Gill_nets",
           "Longlines and Jiggiing",
           "Recreational",
           "Shrimp_trawl",
           "Creels",
           "Mollusc_dredge",
           "Harpoons",
           "Rifles",
           "Kelp_harvester"
)
#apply scaling vector n - parallel
runs <- future_map(scaling,safely(~{
  for (i in 1:length(gears)){
    model <- e2ep_read("SW_Greenland","2011-2019",
                       models.path = "Models",
                       results.path = "Models/SW_Greenland/2011-2019/Results") #run model
    randvals <- runif(n = 11,min = 0,max = 4) #generate random values (length number of gears -1)
    model[["data"]][["fleet.model"]][["gear_mult"]][i] <- model[["data"]][["fleet.model"]][["gear_mult"]][i] * .x #access gear multipliers and change them
    model[["data"]][["fleet.model"]][["gear_mult"]][-i] <- model[["data"]][["fleet.model"]][["gear_mult"]][-i] * randvals #multiple rest of gear multipliers by not i
    print(model[["data"]][["fleet.model"]][["gear_mult"]])
    results <- e2ep_run(model,nyears = 50) #run model
    #saves outputs
    saveRDS(results$final.year.outputs$inshore_landmat,str_glue("./fishing/fishing bounds/changingpower/output2/landings/{.x}_inshore {gears[i]}.rds"))
    saveRDS(results$final.year.outputs$inshore_catchmat,str_glue("./fishing/fishing bounds/changingpower/output2/catch/{.x}_inshore {gears[i]}.rds"))
    saveRDS(results$final.year.outputs$inshore_discmat,str_glue("./fishing/fishing bounds/changingpower/output2/discards/{.x}_inshore {gears[i]}.rds"))
    saveRDS(results$final.year.outputs$offshore_landmat,str_glue("./fishing/fishing bounds/changingpower/output2/landings/{.x}_offshore {gears[i]}.rds"))
    saveRDS(results$final.year.outputs$offshore_catchmat,str_glue("./fishing/fishing bounds/changingpower/output2/catch/{.x}_offshore {gears[i]}.rds"))
    saveRDS(results$final.year.outputs$offshore_discmat,str_glue("./fishing/fishing bounds/changingpower/output2/discards/{.x}_offshore {gears[i]}.rds"))
  }
  
}),.progress = TRUE)
toc() #time

