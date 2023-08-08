## File created to make educated guesses on fishing scenarios
library(dplyr)
# xls files

rm(list = ls()) #fresh start

fishing_activity <- read.csv("Models\\SW_Greenland\\2011-2019\\Param\\fishing_activity_BS_2011-2019.csv") #see what we're dealing with
fishing_activity


#Turn off unrepresented gears
fishing_activity$Activity_.s.m2.d.[9] = 0
fishing_activity$Plough_rate_.m2.s.[9] = 0 #Mollusks

#Alter gear rates
fishing_activity$Activity_.s.m2.d.[10] <- fishing_activity$Activity_.s.m2.d.[10]*2 #Harpoons
fishing_activity$Activity_.s.m2.d.[11] <- fishing_activity$Activity_.s.m2.d.[11]*2 #Rifles

fishing_activity$Activity_.s.m2.d.[8] <- fishing_activity$Activity_.s.m2.d.[8]*10 #Shrimp Trawlers

fishing_activity$Activity_.s.m2.d.[1] <- fishing_activity$Activity_.s.m2.d.[1]*5 #Pelagic Trawl

fishing_activity$Activity_.s.m2.d.[2] <- fishing_activity$Activity_.s.m2.d.[2]*10 #Demersal Otter Trawl

fishing_activity$Activity_.s.m2.d.[4] <- fishing_activity$Activity_.s.m2.d.[4]*20 #Gill Nets

write.csv(fishing_activity,"Models\\SW_Greenland\\2011-2019\\Param\\fishing_activity_SWG_2011-2019.csv")

## Ban Discards ##
fishing_discards <- read.csv("Models\\SW_Greenland\\2011-2019\\Param\\fishing_discards_BS_2011-2019.csv")
fishing_discards$Discardrate_DF[1:9] = 0 #no discarding greenland halibut

fishing_discards$Discardrate_PF[9] = 0
fishing_discards$Discardrate_PF[7] <- 0.1

write.csv(fishing_discards,"Models\\SW_Greenland\\2011-2019\\Param\\fishing_discards_SWG_2011-2019.csv")




