model <- readRDS("Models/modelread.rds") #read in model SWG
results <- readRDS("Models/modelresults.rds") #read in model results SWG

modelBS <- readRDS("Models/BarentsSea2011Model.rds")
resultsBS <- readRDS("Models/BarentsSea2011ModelResults.rds")

primprodphytSWG <- results$final.year.outputs$annual.target.data[1,]
