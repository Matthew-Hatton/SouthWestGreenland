library(magick)
library(ggplot2)
library(dplyr)

TS <- readRDS("Objects\\TS.rds") #read in TS
SP <- readRDS("Objects\\SPATIAL.rds") #read in SP
source("NEMO-MEDUSA\\NEMO Functions\\gif_it.R")

months <- c("January","February","March","April",
            "May","June","July","August","September","October","November","December")

n_iter <- length(names)*length(SP) # Number of iterations of the loop

# Initializes the progress bar
pb <- txtProgressBar(min = 0,      # Minimum value of the progress bar
                     max = n_iter, # Maximum value of the progress bar
                     style = 3,    # Progress bar style (also available style = 1 and style = 2)
                     width = 50,   # Progress bar width. Defaults to getOption("width")
                     char = "=")   # Character used to create the bar
vars <- seq(1,24,1) #number of files
names <- c("Salinity","Temperature","Ice_pres","DIN","Detritus","Phytoplankton") #var names
for (elem in vars){
  tocall <- names(SP)[[elem]]
  for (name in names){
    gif_it(SP[[elem]], name,tocall) #compile gifs
    setTxtProgressBar(pb, i)
  }
    
}
close(pb)


