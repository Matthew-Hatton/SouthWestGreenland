source("@_Region file.R")

# Remove the files which have been replaced by ones for the new region
#(stringr::str_glue("Models/SW_Greenland/2010-2019/Driving/chemistry_BS_2003-2013.csv")) #not updated chemistry yet
unlink("Models/SW_Greenland/2090-2099/Param/physical_parameters_BS.csv")
unlink("Models/SW_Greenland/2090-2099/Driving/physics_BS_2040-2049.csv")  # Delete old file
unlink("Models/SW_Greenland/2090-2099/Driving/chemistry_BS_2040-2049.csv")
#unlink("Models/SW_Greenland/2011-2019/Param/fishing_activity_BS_2011-2019.csv")
#unlink("Models/SW_Greenland/2011-2019/Param/fishing_discards_BS_2011-2019.csv")
#unlink(stringr::str_glue("./StrathE2E/{implementation}/2010-2019/Param/fishing_distribution_CELTIC_SEA.csv")) #NOT DONE FISHING YET

# Update file which tells StrathE2E where to find driving files

Setup_file <- read.csv(stringr::str_glue("Models/SW_Greenland/2011-2019/MODEL_SETUP.csv")) # Read in example Physical drivers

Setup_file[1,1] <- "physical_parameters_SWG.csv"
Setup_file[2,1] <- "physics_SWG_2090-2099.csv"
Setup_file[3,1] <- "chemistry_SWG_2090-2099.csv"
# Setup_file[12,1] <- "fishing_activity_SWG_2090-2099.csv"
# Setup_file[14,1] <- "fishing_discards_SWG_2090-2099.csv"
#Setup_file[3,1] <- stringr::str_glue("chemistry_{toupper(implementation)}_2010-2019.csv")
#Setup_file[16,1] <- stringr::str_glue("fishing_distribution_{toupper(implementation)}.csv")

write.csv(Setup_file,
          file = "Models/SW_Greenland/2090-2099/MODEL_SETUP.csv",
          row.names = F)