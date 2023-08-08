library(StrathE2EPolar)
model <- e2ep_read("SW_Greenland","2011-2019")
results <- e2ep_run(model,nyears = 10)

## VISUALISE MODEL INPUTS ##
e2ep_plot_edrivers(model,"INTERNAL")
e2ep_plot_fdrivers(model,selection = "ACTIVITY")

## CHECK STATIONARY STATE ##
e2ep_plot_ts(model,results,selection = "ECO")

## TROPHIC LEVELS ##
e2ep_plot_trophic(model = model, results = results)

## FISHERY YIELD CURVE ##
pfhr <- seq(0,3,1) #defines planktivorous fish harvest ratios
pf_yield_data <- e2ep_run_ycurve(model = model,selection = "PLANKTIV",nyears = 10,
                                 HRvector = pfhr,HRfixed = 1) #runs model with varying
data <- e2ep_plot_ycurve(model,selection = "PLANKTIV",results = pf_yield_data,
                         title = "Planktivorous yield with baseline demersal fishing \\ SW GREENLAND")


## MIGRATION ##
e2ep_plot_migration(model = model,results = results)

e2ep_plot_migration(model = BSread,results = BSrun)