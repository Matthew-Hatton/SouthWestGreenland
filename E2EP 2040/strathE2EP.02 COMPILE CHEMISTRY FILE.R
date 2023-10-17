rm(list = ls()) #reset

library(MiMeMo.tools)
chem_template <- read.csv("Models/Barents_Sea/2011-2019/Driving/chemistry_BS_2011-2019.csv") #read in example chemistry

My_volumes <- readRDS("Objects/TS.rds") %>% 
  filter(between(Year, 2090, 2099)) %>%                                     # Limit to reference period
  group_by(Compartment, Month) %>%                                          # By compartment and month
  summarise(across(Salinity_avg:Ice_conc_avg, mean, na.rm = T)) %>%         # Average across years for multiple columns
  ungroup() %>% 
  arrange(Month)

chem_new <- mutate(chem_template,
                   ## chem volumes DIN NEEDS TO BE SPLIT INTO AMMONIA AND NITRATE
                   SO_phyt = filter(My_volumes, Compartment == "Offshore S")$Phytoplankton_avg,
                   SI_phyt = filter(My_volumes, Compartment == "Inshore S")$Phytoplankton_avg,
                   D_phyt = filter(My_volumes, Compartment == "Offshore D")$Phytoplankton_avg,
                   SO_detritus = filter(My_volumes, Compartment == "Offshore S")$Detritus_avg,
                   SI_detritus = filter(My_volumes, Compartment == "Inshore S")$Detritus_avg,
                   D_detritus = filter(My_volumes, Compartment == "Offshore D")$Detritus_avg)

write.csv(chem_new, file = "Models/SW_Greenland/2090-2099/Driving/chemistry_SWG_2090-2099.csv", row.names = F)