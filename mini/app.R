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
  #    """Import data from file
  #
  #    Returns
  #    -------
  #    cleaned up df 
  #    """
  path <- "data/processed/DSCI532-CDN-CRIME-DATA.tsv"
  df <- read.delim(path)
  
  ### Data Wrangling 
  df <- df %>%
    drop_na(Value) %>%
    mutate(Geography = str_replace(Geography, " \\[[\\d]*\\]", "")) %>%
    mutate(Violation.Description = str_replace(Violation.Description, " \\[[\\d]*\\]", "")) 
  
  df
}

import_map_data <- function(){
  readRDS("data/processed/canadian_provinces.rds")
}

PROVINCES <- import_map_data()
DATA <- import_data()

app <- Dash$new(external_stylesheets = dbcThemes$BOOTSTRAP, suppress_callback_exceptions=TRUE)

app$layout(
  htmlDiv(list(
    dccTabs(id='crime-dashboard-tabs', value='tab-1', 
            children = list(
              dccTab(label='Geographic Crime Comparisons', value='tab-1'), 
              dccTab(label='Crime Trends', value='tab-2')
              )
            ),
    htmlDiv(id='crime-dashboard-content'))
))

app$callback(
  output('crime-dashboard-content', 'children'),
  params = list(input('crime-dashboard-tabs', 'value')),
  function(tab){ 
    
    data = import_data() 
    
    if(tab == 'tab-1') {
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
  params = list(input(id='metric_select', property='value')),
  function(x){
    renderLeaflet({leaflet() %>% addTiles()})
    #ggplotly(
    #  ggplot(gapminder, aes(x = year)) + geom_histogram(bins=10)
    #)
  }
)

# CMA plot, tab1
app$callback(
  output('cma_barplot', 'children'),
  list(
    input('metric_select', 'value'), 
    input('violation_select', 'value')
  ),
  function(metric, violation) {

    df <- DATA %>%
      filter(Metric == !!sym(metric)) %>%
      filter(Violation.Description == !!sym(violation)) %>%
      filter(Geo_Level == "CMA")
    
    plot <- df %>%
      ggplot(aes(x = Value, y = Geography, tooltip = Value)) +
      geom_bar(width = 0.5) + # size may need changing
      labs(x = !!sym(metric), y = 'Census Metropolitan Area (CMA)') +
      ggtitle(!!sym(violation))
    
   ggplotly(plot, tooltip = 'Value')
})

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
  output('metric_select', 'value'),
  list(input('crime-dashboard-tabs', 'value')),
  function(...){
    "Rate per 100,000 population"
  }
)


app$run_server(debug=TRUE, suppress_callback_exceptions = TRUE)
