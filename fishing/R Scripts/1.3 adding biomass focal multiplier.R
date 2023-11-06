rm(list = ls()) #reset
#load in biomass list to tweak
biomass_lst <- readRDS(file = "fishing/fishing bounds/changingpower/biomassoutputs/biomass_list.Rds")

##scuffed solution
#could split each list up into its parts and then just add the focal multiplier on manually? It would be messy, but not sure
#of another way to get it done rn

#count how many of each there are: `Focal Gear` varies
total <- 0
for (i in biomass_lst){
  # Check if the 'Focal Gear' column in the data frame is equal to the target value
  if ("Focal Gear" %in% colnames(i) && i$`Focal Gear` == "Kelp_harvester.rds"){
    total <- total + 1
  }
}
print(total)
###796 pel trawl
###802 dem otter trawl
###798 dem seine
###798 gill
###802 longlines
###796 rec
###798 shrimp
###800 creels
###794 mollusc
###796 harpoons
###800 rifles
###800 kelp

#split up list
peltrawl <- biomass_lst[1:796] %>% 
  mapply(`[<-`, ., 'Focal Multiplier', value = rep(scaling,each = 2),
         SIMPLIFY = FALSE)

demotter <- biomass_lst[797:1598] %>% 
  mapply(`[<-`, ., 'Focal Multiplier', value = rep(scaling,each = 2),
         SIMPLIFY = FALSE)

demseine <- biomass_lst[1599:2396] %>% 
  mapply(`[<-`, ., 'Focal Multiplier', value = rep(scaling,each = 2),
         SIMPLIFY = FALSE)

gill <- biomass_lst[2397:3194] %>% 
  mapply(`[<-`, ., 'Focal Multiplier', value = rep(scaling,each = 2),
         SIMPLIFY = FALSE)

longlines <- biomass_lst[3193:3192+802] %>% 
  mapply(`[<-`, ., 'Focal Multiplier', value = rep(scaling,each = 2),
         SIMPLIFY = FALSE)

rec <- biomass_lst[3994:3994+796] %>% 
  mapply(`[<-`, ., 'Focal Multiplier', value = rep(scaling,each = 2),
         SIMPLIFY = FALSE)

shrimp <- biomass_lst[4790:4790+798] %>% 
  mapply(`[<-`, ., 'Focal Multiplier', value = rep(scaling,each = 2),
         SIMPLIFY = FALSE)

creels <- biomass_lst[5588:5588+800] %>% 
  mapply(`[<-`, ., 'Focal Multiplier', value = rep(scaling,each = 2),
         SIMPLIFY = FALSE)

mollusc <- biomass_lst[6388:6388+794] %>% 
  mapply(`[<-`, ., 'Focal Multiplier', value = rep(scaling,each = 2),
         SIMPLIFY = FALSE)

harpoons <- biomass_lst[7182:7182+796] %>% 
  mapply(`[<-`, ., 'Focal Multiplier', value = rep(scaling,each = 2),
         SIMPLIFY = FALSE)

rifles <- biomass_lst[7978:7978+800] %>% 
  mapply(`[<-`, ., 'Focal Multiplier', value = rep(scaling,each = 2),
         SIMPLIFY = FALSE)

kelp <- biomass_lst[8778:8778+800] %>% 
  mapply(`[<-`, ., 'Focal Multiplier', value = rep(scaling,each = 2),
         SIMPLIFY = FALSE)

#rejoin list
biomass_lst <- c(peltrawl,demotter,demseine,gill,longlines,rec,shrimp,creels,
                 mollusc,harpoons,rifles,kelp)
#save biomasses with multipliers
saveRDS(biomass_lst,file = "fishing/fishing bounds/changingpower/biomassoutputs/bm lst with mult.Rds")
