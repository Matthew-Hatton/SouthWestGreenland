ts_plot_mult <- function(vars, x_min1, x_max1, x_min2, x_max2) {
  library(patchwork)
  
  # Create an empty list to store the plots
  plots <- list()
  
  # Loop through each variable
  for (var in vars) {
    # Generate the plot for the current variable
    ts <- ggplot2::ggplot(TS, aes(x = date, y = get(var), colour = Compartment)) +
      geom_rect(xmin = x_min1, xmax = x_max1, ymin = -Inf, ymax = Inf, fill = "lightgrey", alpha = 0.05, color = "NA") +
      geom_rect(xmin = x_min2, xmax = x_max2, ymin = -Inf, ymax = Inf, fill = "lightgrey", alpha = 0.05, color = "NA") +
      labs(x = NULL) +  # Remove x-axis label
      ggplot2::theme_minimal() +
      ggplot2::theme(legend.position = "none") +
      ggplot2::labs(caption = paste("NM", var, "time series by compartment"), y = var) +
      ggplot2::geom_line(size = 0.2) +
      ggplot2::geom_smooth(span = 0.008, size = 0.2, se = FALSE) +
      NULL
    
    # Append the plot to the list
    plots[[var]] <- ts
  }
  
  # Combine the plots using patchwork
  combined_plot <- patchwork::wrap_plots(plots, nrow = length(vars), guides = "collect")
  
  # Save the combined plot
  ggplot2::ggsave("combined_plot.png", plot = combined_plot, width = 16, height = 10, units = "cm", dpi = 500, bg = "white")
  
  # Return the combined plot
  return(combined_plot)
}
