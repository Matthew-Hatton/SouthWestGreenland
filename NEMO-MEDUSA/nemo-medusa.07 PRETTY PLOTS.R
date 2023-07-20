rm(list = ls(all.names = TRUE))

library(MiMeMo.tools)
library(furrr)
library(ggplot2)

TS <- readRDS("Objects/TS.rds") #read in TS
TS$Shore <- ifelse(TS$Shore == "Offshore" & TS$slab_layer == "D", "Offshore Deep", TS$Shore) #changes offshore to offshore deep

# Convert categorical x-values to numeric
x_2010 <- as.Date("2010-01-01")
x_2019 <- as.Date("2019-01-01")
x_2040 <- as.Date("2040-01-01")
x_2049 <- as.Date("2049-01-01")
x_2090 <- as.Date("2090-01-01")
x_2099 <- as.Date("2099-01-01")

ts_plot <- function(var) {
  
  ts <- ggplot2::ggplot(TS, aes(x=date, y= get(var), colour = Compartment)) +
    ggplot2::geom_line(size = 0.2) +
    ggplot2::geom_smooth(span = 0.008, size = 0.2, se = FALSE) +
    ggplot2::theme_minimal() +
    ggplot2::theme(legend.position = "top",panel.grid.major.y = element_blank(),
                   panel.grid.minor.y = element_blank()) +
    ggplot2::labs(caption = paste("NM", var, "time series by compartment"), y = var) +
    NULL
  return(ts)
}


tmp <- ts_plot("Snow_Thickness_avg")
tmp$layers <- c(geom_rect(xmin = x_2010,xmax = x_2019,ymin = -Inf,ymax = Inf, fill = "lightgrey",alpha = 0.05,color = "NA"),
                geom_rect(xmin = x_2040,xmax = x_2049,ymin = -Inf,ymax = Inf, fill = "lightgrey",alpha = 0.05,color = "NA"),
                geom_rect(xmin = x_2090,xmax = x_2099,ymin = -Inf,ymax = Inf, fill = "lightgrey",alpha = 0.05,color = "NA"),
                tmp$layers)

tmp +
  labs(x = "Year",y = "Snow Thickness Average") +
  scale_x_date(breaks = as.Date(c("1975-01-01", "2000-01-01", "2010-01-01", "2019-01-01", "2040-01-01", "2049-01-01", "2100-01-01")),
               date_labels = "%Y")

#For save
setwd("C:/Users/psb22188/Documents/PhD/22-23/West Greenland/NEMO/Data Wrangling/Jacks Way/Clean Figures")

ggplot2::ggsave("TS_Snow_Thickness_avg.png", width = 16, height = 10,
                units = "cm", dpi = 500, bg = "white")
