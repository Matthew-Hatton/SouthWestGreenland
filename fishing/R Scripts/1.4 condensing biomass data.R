biomass_lst <- readRDS(file = "fishing/fishing bounds/changingpower/biomassoutputs/bm lst with mult.Rds")
biomass_result <- do.call(rbind,biomass_lst)
saveRDS(biomass_result,"fishing/fishing bounds/changingpower/biomassoutputs/biomass DF.Rds")