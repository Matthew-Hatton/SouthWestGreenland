
library(StrathE2EPolar)
model <- e2ep_read("SW_Greenland","2011-2019")
results <- e2ep_run(model,nyears = 50)                                # Run the model to find s.s

e2ep_plot_ts(model, results) #plot ts check for s.s

#### Update starting conditions ####

e2ep_extract_start(model, results, csv.output = TRUE)                # Update starting conditions to the end of a simulation

file.rename("Models/SW_Greenland/2011-2019/Param/initial_values-base.csv",
            "Models/SW_Greenland/2011-2019/Param/initial_values_SWG_2010-2019.csv")
unlink("Models/SW_Greenland/2011-2019/Param/initial_values_BS_2011-2019.csv")

## Update set up file

Setup_file <- read.csv("Models/SW_Greenland/2011-2019/MODEL_SETUP.csv")

Setup_file[4,1] <- "initial_values_SWG_2011-2019.csv"

write.csv(Setup_file,
          file = stringr::str_glue("Models/SW_Greenland/2011-2019/MODEL_SETUP.csv"),
          row.names = F)