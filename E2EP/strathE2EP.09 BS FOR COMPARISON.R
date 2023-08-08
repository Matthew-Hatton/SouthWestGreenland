model_BS <- e2ep_read("Barents_Sea","2011-2019")
results_BS <- e2ep_run(model,nyears = 10)

saveRDS(results_BS,"Models\\BarentsSea2011Modelresults.rds")
saveRDS(model_BS,"Models\\BarentsSea2011Model.rds")