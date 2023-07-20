#Function to take a file name and variable from NEMO-MEDUSA model output and create a gif of monthly averages.

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
