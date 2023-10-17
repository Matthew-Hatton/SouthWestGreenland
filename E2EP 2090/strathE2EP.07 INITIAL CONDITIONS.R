rm(list=ls()) #reset
library(StrathE2EPolar)
model <- e2ep_read("SW_Greenland","2090-2099",
                   models.path = "Models")
results <- e2ep_run(model,nyears = 100)                                # Run the model to find s.s

e2ep_plot_ts(model, results) #plot ts check for s.s

#### Update starting conditions ####
Setup_file <- read.csv("Models/SW_Greenland/2090-2099/MODEL_SETUP.csv")

Setup_file[4,1] <- "initial_values_SWG_2090-2099.csv"
write.csv(Setup_file,
          file = stringr::str_glue("Models/SW_Greenland/2090-2099/MODEL_SETUP.csv"),
          row.names = F) #change what model setup is expecting
e2ep_extract_start(model, results, csv.output = TRUE)                # Update starting conditions to the end of a simulation

file.rename("Models/SW_Greenland/2090-2099/Param/initial_values-base.csv",
            "Models/SW_Greenland/2090-2099/Param/initial_values_SWG_2090-2099.csv")
unlink("Models/SW_Greenland/2090-2099/Param/initial_values_BS_2040-2049.csv")

## Update set up file