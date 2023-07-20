library(magick)
library(ggplot2)
library(dplyr)

TS <- readRDS("Objects\\TS.rds") #read in TS
SP <- readRDS("Objects\\SPATIAL.rds")

#1184 data points per month. Split df into 12 equal compartments, maybe that's a long way of doing it.

overall_temperature_range <- c(-2,15)
overall_salinity_range <- c(22,35)

months <- c("January","February","March","April",
            "May","June","July","August","September","October","November","December")

# Loop through each month and create and save individual plots
gif_it <- function(file,variable,tocall){
  output_dir <- paste("Clean Grid Figures/Animation/", tocall, sep = "") #must first create file
  if (!dir.exists(output_dir)){
    dir.create(output_dir)
  }
  var_dir <- paste(output_dir,"/",variable,sep = "")
  dir.create(var_dir)
  for (m in unique(file$Month)) {
    # Subset the data for the current month
    data_month <- subset(file, Month == m)
    # Create the ggplot for the current month
    
    limits <- switch(variable,
                     "Temperature" = c(-2, 15),
                     "Salinity" = c(22, 35),
                     "Ice_pres" = c(0, 1),
                     "DIN" = c(0,20),
                     "Detritus" = c(0,0.5),
                     "Phytoplankton" = c(0,0.7),
                     default = c(0, 100))
    
    p <- ggplot() +
      geom_raster(data = data_month,aes(x = x,y = y,fill = .data[[variable]])) +
      labs(title = paste(months[m]),
           fill = paste(variable)) +
      theme_minimal() +
      theme(axis.title.y = element_blank(),
            axis.title.x = element_blank(),
            axis.ticks.x = element_blank(),axis.ticks.y = element_blank(),
            axis.text.x=element_blank(),axis.text.y=element_blank(),
            panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
      scale_fill_viridis_c(option = "mako",limits = limits)
    ggsave(filename = paste(m,".png", sep = ""),
           plot = p, width = 8, height = 6,background = "black",path = var_dir)
    
  }
  imgs <- list.files(var_dir,pattern = "\\.png")
  # Find the indices of elements that need to be moved to the end
  indices_to_move <- which(imgs %in% c("10.png", "11.png", "12.png"))
  # Create a new list with elements rearranged
  imgs <- c(imgs[-indices_to_move], imgs[indices_to_move]) #correct order
  img_lst <- lapply(paste(var_dir,"/",imgs,sep = ""),image_read)#read the images
  img_joined <- image_join(img_lst)#... and join them
  img_animated <- image_animate(img_joined,fps = 4)#... and animate them
  image_write(img_animated,paste(var_dir,"/",tocall," ",variable,".gif",sep = ""))
}


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
    gif_it(SP[[elem]], name,tocall)
    setTxtProgressBar(pb, i)
  }
    
}

close(pb)


