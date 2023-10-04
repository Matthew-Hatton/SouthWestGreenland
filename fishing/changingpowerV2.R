#This is code to statically step through just one gear (OLD)

rm(list = ls()) #fresh start
library(tidyverse)
library(doParallel)
library(foreach)
library(StrathE2EPolar)
library(furrr)
library(tictoc)

tic() #time
plan("multisession")

#define scaling vectors
scaling <- seq(0,2,0.00005)

#apply scaling vector n - parallel
runs <- future_map(scaling,safely(~{
model <- e2ep_read("SW_Greenland","2011-2019",
                     models.path = "Models",
                     results.path = "Models/SW_Greenland/2011-2019/Results") #run model
  
model[["data"]][["fleet.model"]][["gear_mult"]] <- model[["data"]][["fleet.model"]][["gear_mult"]] * .x #access gear multipliers and change them

results <- e2ep_run(model,nyears = 50) #run model
#saves outputs
saveRDS(results$final.year.outputs$inshore_landmat,str_glue("./fishing/fishing bounds/changingpower/output/landings/{.x}_inshore.rds"))
saveRDS(results$final.year.outputs$inshore_catchmat,str_glue("./fishing/fishing bounds/changingpower/output/catch/{.x}_inshore.rds"))
saveRDS(results$final.year.outputs$inshore_discmat,str_glue("./fishing/fishing bounds/changingpower/output/discards/{.x}_inshore.rds"))
saveRDS(results$final.year.outputs$offshore_landmat,str_glue("./fishing/fishing bounds/changingpower/output/landings/{.x}_offshore.rds"))
saveRDS(results$final.year.outputs$offshore_catchmat,str_glue("./fishing/fishing bounds/changingpower/output/catch/{.x}_offshore.rds"))
saveRDS(results$final.year.outputs$offshore_discmat,str_glue("./fishing/fishing bounds/changingpower/output/discards/{.x}_offshore.rds"))
}))
toc() #time

