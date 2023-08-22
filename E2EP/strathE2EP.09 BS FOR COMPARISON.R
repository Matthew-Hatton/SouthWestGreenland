
model_BS <- e2ep_read("Barents_Sea","2011-2019",models.path = "Models")
results_BS <- e2ep_run(model_BS,nyears = 10)
e2ep_plot_ts(model_BS,results_BS,selection = "ECO")

# 
# saveRDS(results_BS,"Models\\BarentsSea2011Modelresults.rds")
# saveRDS(model_BS,"Models\\BarentsSea2011Model.rds")