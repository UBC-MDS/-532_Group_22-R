library(dash)
library(dashHtmlComponents)
library(dashCoreComponents)
library(dashBootstrapComponents)
library(tidyverse)
library(ggplot2)
library(cowplot)
library(gapminder)
library(plotly)
library(leaflet)
library(tidyverse)
library(stringr)
library(spdplyr)
library(dplyr)

source("src/tab1.R")

# Pull initial data for plots
import_data <- function() {
  path <- "data/processed/DSCI532-CDN-CRIME-DATA.tsv"
  df <- read.delim(path)
  
  ### Data Wrangling 
  df %>%
    drop_na(Value) %>%
    mutate(Geography = str_replace(Geography, " \\[[\\d|\\/]*\\]", "")) %>%
    mutate(Violation.Description = str_replace(Violation.Description, " \\[[\\d]*\\]", "")) 
}

import_map_data <- function(){
  readRDS("data/processed/canadian_provinces.rds")
}

PROVINCES <- import_map_data()
DATA <- import_data()

app <- Dash$new(suppress_callback_exceptions = TRUE,
                external_stylesheets = dbcThemes$BOOTSTRAP)

app$title("Canadian Crime Dashboard")

app$layout(
  htmlDiv(list(
    dbcTabs(
      id = 'crime-dashboard-tabs',
      children = list(
        dbcTab(label='Geographic Crime Comparisons', tab_id='tab-1'),
        dbcTab(label='Crime Trends', tab_id='tab-2')
        )
      ),
    htmlDiv(id='crime-dashboard-content')
    ))
)

app$callback(
  output('crime-dashboard-content', 'children'),
  params = list(input('crime-dashboard-tabs', 'active_tab')),
  function(tab){ 
    if(tab == "tab-1") {
        return(htmlDiv(generate_tab_1_layout())) 
    }
    else if (tab == 'tab-2') {
      #return(htmlDiv(generate_tab_1_layout()))
    }
  }
)

# Choropleth map, tab1
app$callback(
  output = output(id='choropleth', property='figure'),
  list(
    input('metric_select', 'value'), 
    input('violation_select', 'value'),
    input('year_select', 'value')
  ),
  function(metric, violation, year){
    
    df <- DATA %>% 
      filter(Geo_Level == "PROVINCE") %>% 
      filter(Metric == metric) %>%
      filter(Violation.Description == violation) %>%
      filter(Year == year)
    
    province_data <- left_join(PROVINCES, df, by=c("NAME"="Geography"))
    
    num_colours <- 13
    bins <- round(seq(from=0, to=max(df$Value), length.out = num_colours), 0)
    
    # A few pallette options
    #pallete <- "inferno"
    pallete <- "RdYlBu"
    #pallete <- topo.colors(num_colours)
    #pallete <- colorRampPalette(c("#FF0000", "#000000", "#33FF00"))(num_colours)
    
    pal <- colorBin(pallete, domain = province_data$Value, bins = bins, reverse = TRUE)
    
    fig <- plot_ly()
    fig <- fig %>% 
      add_trace(type="choropleth")
    
    fig
  }
)

# CMA plot, tab1
app$callback(
  output('cma_barplot', 'figure'),
  list(
    input('metric_select', 'value'), 
    input('violation_select', 'value'),
    input('year_select', 'value')
  ),
  function(metric, violation, year) {

    df <- DATA %>%
      filter(Metric == metric) %>%
      filter(Violation.Description == violation) %>%
      filter(Geo_Level == "CMA") %>%
      filter(Year == year)
    
    plot <- df %>%
      ggplot(aes(x = Value, y = reorder(Geography, -Value))) +
      geom_bar(width = 0.5, stat = "identity") + # size may need changing
      labs(x = metric, y = 'Census Metropolitan Area (CMA)') +
      ggtitle(paste(year, violation))
    
    ggplotly(plot, tooltip="Value")
   }
)

get_dropdown_options <- function(col){
  unique(col) %>% map(function(val) list(label = val, value = val))
}

app$callback(
  output('metric_select', 'options'),
  list(input('crime-dashboard-tabs', 'value')),
  function(...){
    get_dropdown_options(DATA$Metric)
  }
)

app$callback(
  output('violation_select', 'options'),
  list(input('crime-dashboard-tabs', 'value')),
  function(...){
    get_dropdown_options(DATA$Violation.Description)
  }
)

app$run_server(debug=FALSE)
