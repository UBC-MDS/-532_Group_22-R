library(leaflet)
library(tidyverse)
library(stringr)
library(spdplyr)
library(dplyr)

# Temporary
setwd("~/mds/532/532_Group_22-R")

# RDS File Source: https://github.com/sbabicki/heatmapper/blob/master/geomap/data/CAN_1.rds
provinces <- readRDS("data/processed/canadian_provinces.rds")

df <- read.delim("data/processed/DSCI532-CDN-CRIME-DATA.tsv")
df <- df %>% 
  drop_na(Value) %>%
  mutate(Geography = str_replace(Geography, " \\[[\\d]*\\]", "")) %>%
  filter(Geo_Level == "PROVINCE") %>% 
  filter(Metric == "Rate per 100,000 population") %>%
  filter(Violation.Description == "Total, all violations [0]") %>%
  filter(Year == 2002)

province_data <- left_join(provinces, df, by=c("NAME"="Geography"))

num_colours <- 13
bins <- seq(from=0, to=max(df$Value), length.out = num_colours)

# A few pallette options
#pallete <- "inferno"
#pallete <- "RdYlBu"
#pallete <- topo.colors(num_colours)
pallete <- colorRampPalette(c("#FF0000", "#000000", "#33FF00"))(num_colours)

pal <- colorBin(pallete, domain = province_data$Value, bins = bins, reverse = TRUE)

labels <- sprintf(
  "<strong>%s</strong><br/>%g per 100k population",
  province_data$NAME, province_data$Value
) %>% lapply(htmltools::HTML)

# Code based on tutorial: https://rstudio.github.io/leaflet/choropleths.html
province_data %>%
  leaflet() %>% 
  addTiles() %>% 
  addPolygons(
    fillColor = ~pal(Value),
    weight = 1,
    opacity = 1,
    color = "black",
    dashArray = "1",
    fillOpacity = 0.7,
    highlight = highlightOptions(
      weight = 2,
      color = "orange",
      fillOpacity = 0.7,
      bringToFront = TRUE),
    label = labels,
    labelOptions = labelOptions(
      style = list("font-weight" = "normal", padding = "3px 8px"),
      textsize = "15px",
      direction = "auto"))
