library(StrathE2EPolar)
library(ggplot2)
model <- e2ep_read("SW_Greenland","2011-2019",
                   models.path = "Models",
                   results.path = "Models/SW_Greenland/2011-2019/Results")
results <- e2ep_run(model,nyears = 10)
## CHECK STATIONARY STATE ##
e2ep_plot_ts(model,results,selection = "ECO")


## VISUALISE MODEL INPUTS ##
e2ep_plot_edrivers(model,"INTERNAL")

e2ep_plot_fdrivers(model,selection = "ACTIVITY")

## TROPHIC LEVELS ##
e2ep_plot_trophic(model = model, results = results)

# FISHERY YIELD CURVE ##
pfhr <- seq(0,10,2) #defines planktivorous fish harvest ratios
pf_yield_data <- e2ep_run_ycurve(model = model,selection = "DEMERSAL",nyears = 10,
                                 HRvector = pfhr,HRfixed = 1) #runs model with varying
data <- e2ep_plot_ycurve(model,selection = "DEMERSAL",results = pf_yield_data,
                         title = "Planktivorous yield with baseline Demersal fishing \\ SW GREENLAND")

ggplot() +
  geom_vline(xintercept = 1,linetype = "dashed") +
  geom_line(data = data,aes(x = DemFishHRmult,y = DemFishbiom),linewidth = 1,color = "blue") +
  #geom_line(data = data_BS,aes(x = PlankFishHRmult,y = PlankFishbiom),linewidth = 1,color = "Blue") +
  labs(x = "Demersal Fish HR Multiplier",y = "Demersal Fish Biomass") +
  NULL

ggsave("DemFishBiom.PNG")






## BS for comparison ##
BSread <- readRDS("Models\\BarentsSea2011Model.rds")
BSrun <- readRDS("Models\\BarentsSea2011Modelresults.rds")

e2ep_plot_ts(model = BSread,results = BSrun,selection = "ECO")



## MIGRATION ##
e2ep_plot_trophic(model = model,results = results)

e2ep_plot_trophic(model = BSread,results = BSrun)


## COMPARE ##
e2ep_compare_runs_bar(model1 = BSread,results1 = BSrun,model2 = model,results2 = results,
                      bpmin=(-100),bpmax=(+600),
                      log.pc = "PC")

e2ep_plot_catch(model = model,results = results,selection = "BY_GUILD")
e2ep_plot_catch(model = BSread,results = BSrun,selection = "BY_GUILD")
