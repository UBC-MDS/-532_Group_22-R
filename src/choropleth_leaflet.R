library(leaflet)
library(tidyr)

provinces <- readRDS("data/processed/canadian_provinces.rds")
leaflet(provinces) %>% 
  addTiles() %>% 
  addPolygons()

