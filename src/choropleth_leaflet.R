library(leaflet)
library(tidyr)

# RDS File Source: https://github.com/sbabicki/heatmapper/blob/master/geomap/data/CAN_1.rds
provinces <- readRDS("data/processed/canadian_provinces.rds")
leaflet(provinces) %>% 
  addTiles() %>% 
  addPolygons()

