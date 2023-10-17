
model_BS <- e2ep_read("Barents_Sea","2011-2019",models.path = "Models")
results_BS <- e2ep_run(model_BS,nyears = 10)
e2ep_plot_ts(model_BS,results_BS,selection = "ECO")

pfhr <- seq(0,10,2) #defines planktivorous fish harvest ratios
pf_yield_data_BS <- e2ep_run_ycurve(model = model_BS,selection = "PLANKTIV",nyears = 10,
                                 HRvector = pfhr,HRfixed = 1) #runs model with varying
data_BS <- e2ep_plot_ycurve(model_BS,selection = "PLANKTIV",results = pf_yield_data_BS,
                         title = "Planktivorous yield with baseline demersal fishing \\ BS")


# 
# saveRDS(results_BS,"Models\\BarentsSea2011Modelresults.rds")
# saveRDS(model_BS,"Models\\BarentsSea2011Model.rds")