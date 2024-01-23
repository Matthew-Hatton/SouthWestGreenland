#rough crops to region (to reduce file size)
crop <- function(file){
  filter(file,cell_ll_lat < 72.5) %>%
    filter(.,cell_ll_lat > 59) %>%
    filter(.,cell_ll_lon < -45) %>%
    filter(.,cell_ll_lon >-61)
}
