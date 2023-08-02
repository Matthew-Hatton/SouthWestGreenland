#make aggregations based on the grain size classification
rm(list = ls()) #fresh start

percent_compositions <- read.csv("Sediment\\RAW\\grainsizeanalysisKrawczyk.csv") %>% #read in data from Krawczyk
  subset(!is.na(Silt...clay....)) %>% #drop Na rows
  select(-c(Station.ID.number,Image.ID.number,Cruise.Year,Latitude.N,Longitude.E,Gear,Reference)) #drop uneeded cols
  
percent_compositions$Sediment.class <- c("Sand","Mud","Mud","Mud","Mud","Mud",
                                         "Gravel","Gravel","Sand","Gravel","Gravel",
                                         "Sand","Mud","Mud","Gravel","Gravel","Mud") #rename sediment classes appropriately (based on percentages)

grainsizes <- data.frame("Silt/Clay" = 0.00006,
                         "Fine Sand" = 0.1875,
                         "Medium Sand" = 0.375,
                         "Coarse Sand" = 0.75,
                         "Gravel" = 3,
                         "Cobbles" = 160) #defines grain sizes based on Wentworth 1922

sediment_class <- select(percent_compositions,Sediment.types,Sediment.class) # store sediment class data temporarily
percent_compositions <- select(percent_compositions,-c(Sediment.types,Sediment.class)) %>% #remove these for easier calculation
  .[,1:ncol(.)]/100 #convert percentages

###find weighted median grain sizes of each class###
for (i in 1:17){
  percent_compositions[i,] <- percent_compositions[i,] * grainsizes
} 

percent_compositions$WeightedMedGrainSize <- rowSums(percent_compositions)
####
percent_compositions$Sediment.types <- sediment_class$Sediment.types#add back on columns
percent_compositions$Sediment.class <- sediment_class$Sediment.class


averages <- aggregate(WeightedMedGrainSize ~ Sediment.class,data = percent_compositions, FUN = mean) #average over all classes
averages[nrow(averages) + 1,] = c("Rock",160) #adds on rock with median grain size

sediment_areas <- readRDS("Objects\\Sediment Proportions.RDS")


inshore <- filter(sediment_areas,Shore == "Inshore") %>%  #filters inshore
  select(-c(area,Shore))
  
offshore <- filter(sediment_areas,Shore == "Offshore") %>%  #filters offshore
  select(-c(area,Shore))                    #and drop unnecessary


### AGGREGATE ###
#convert "units" class to numeric values
inshore_proportion <- as.numeric(inshore$proportion)
offshore_proportion <- as.numeric(offshore$proportion)

#aggregate
inshore_aggregate <- data.frame(Sediment = c("Rock", "Mud", "Sand", "Gravel"),
                      Proportion = c(sum(inshore_proportion[1:2]),
                                     sum(inshore_proportion[c(6)]),
                                     sum(inshore_proportion[c(5, 7)]),
                                     sum(inshore_proportion[c(3,4)])))

offshore_aggregate <- data.frame(Sediment = c("Rock", "Mud", "Sand", "Gravel"),
                      Proportion = c(sum(offshore_proportion[1:2]),
                                     sum(offshore_proportion[6]),
                                     sum(offshore_proportion[c(5,7)]),
                                     sum(inshore_proportion[c(3,4)])))

sum(inshore_proportion,offshore_proportion) #check (should equal 1)

saveRDS(inshore_aggregate,"Objects\\Inshore sediment proportions.RDS")
saveRDS(offshore_aggregate,"Objects\\Offshore sediment proportions.RDS")