rm(list = ls()) #reset
library(tidyverse)
library(ggplot2)

powermatall <- read.csv(file = "Models\\SW_Greenland\\2040-2049\\Param\\fishing_power_BS_2011-2019.csv") %>% #read fishing power matrix
              subset(select = -c(Gear_code)) #drop gear codes
powermat <- powermatall[,-1]
powermat$Gears <- powermatall[,1]
colnames(powermat) <- c("Planktiv. Fish","Dem. Fish","Mig. Fish","Susp/Dep. Benthos","Carn/scav. Benthos",
                        "Carniv.Zoo","Birds","Pinnipeds","Cetaceans","Macrophytes","Gears") #creates new column names
powermat <- pivot_longer(data = powermat,cols = c("Planktiv. Fish","Dem. Fish","Mig. Fish","Susp/Dep. Benthos","Carn/scav. Benthos",
                                                  "Carniv.Zoo","Birds","Pinnipeds","Cetaceans","Macrophytes"),names_to = "Guild") #tidy
powermat$value <- log10(powermat$value)
powermat$value[!is.finite(powermat$value)] <- NA
# powermat <- powermat[powermat$value != 0, ] #removes NA values
#powermat$value <- powermat$value - min(powermat$value+0.1) #reset to 0
                         
ggplot() +
  geom_tile(powermat,mapping = aes(x = Guild,y = Gears,fill = value),color = "black",linewidth = 0.5) +
  scale_fill_gradient(low = 'white', high = '#1F449C',na.value = "transparent") +
  #paletteer::scale_fill_paletteer_c("ggthemes::Orange",na.value = "transparent") +
  #scale_fill_viridis_c(option = "B",direction = -1,na.value = "white") +
  scale_x_discrete(expand = c(0,0)) +
  scale_y_discrete(expand = c(0,0)) +
  geom_text(data = ~ subset(powermat, is.na(value)), aes(x = Guild,y = Gears,label = "X"),color = "black",size = 7) + #adds x's to NA's
  labs(fill = "log(Power)") +
  theme(axis.text.x = element_text(angle = 90),panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_rect(fill = "white")) #plots
ggsave("fishing/Misc for talk/figures/What gear catches what guild with legend.png")
