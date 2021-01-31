library(dash)
library(dashHtmlComponents)
library(dashCoreComponents)
library(dashBootstrapComponents)
library(tidyverse)
library(ggplot2)
library(cowplot)
library(plotly)
library(stringr)
library(spdplyr)
library(dplyr)
library(rjson)

source("src/tab1.R")
source("src/tab2.R")

# Pull initial data for plots
import_data <- function() {
  path <- "data/processed/DSCI532-CDN-CRIME-DATA.tsv"
  df <- read.delim(path)
  
  ### Data Wrangling 
  df %>%
    drop_na(Value) %>%
    mutate(Geography = str_replace(Geography, " \\[[\\d|\\/]*\\]", "")) %>%
    mutate(Violation.Description = str_replace(Violation.Description, " \\[[\\d]*\\]", ""))# %>%
    # mutate(Geo_Level = ifelse(Geography == "Prince Edward Island", str_replace(Geo_Level, "CMA", "PROVINCE"), Geo_Level)) 
}

# Import geo data for choropleth
import_map_data <- function(){
  # readRDS("data/processed/canadian_provinces.rds")
  province_geom <- fromJSON(file = 'data/raw/geojson/provinces_simple.geojson')
  
  # Add ID field to each feature in the JSON
  for (val in seq_along(province_geom$features)) {
    province_geom$features[[val]]$id <- province_geom$features[[val]]$properties$PRENAME
  }
  province_geom
}

# Global vars
PROVINCES <<- import_map_data()
DATA <<- import_data()

app <- Dash$new(suppress_callback_exceptions = TRUE,
                external_stylesheets = dbcThemes$BOOTSTRAP)

app$title("Canadian Crime Dashboard")

# Page Structure
app$layout(
  htmlDiv(list(
    dbcTabs(   # isn't it dccTabs ? Dashr documentation core components (CAL)
      id = 'crime-dashboard-tabs',
      children = list(
        dbcTab(label='Geographic Crime Comparisons', tab_id='tab-1'),
        dbcTab(label='Crime Trends', tab_id='tab-2')
        )
      ),
    htmlDiv(id='crime-dashboard-content')
    ))
)

# Tab Selection
app$callback(
  output('crime-dashboard-content', 'children'),
  params = list(input('crime-dashboard-tabs', 'active_tab')),
  function(tab){ 
    if(tab == "tab-1") {
        return(htmlDiv(generate_tab_1_layout())) 
    }
    else if (tab == 'tab-2') {
        return(htmlDiv(generate_tab_2_layout()))
    }
  }
)

# Tab 1 Choropleth map
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

    fig <- plot_ly()
    fig <- fig %>% add_trace(
      type = "choropleth",
      geojson = PROVINCES,
      locations = df$Geography,
      z = df$Value,
      colorscale = 'Viridis',
      zmin = min(df$Value),
      zmax = max(df$Value),
      marker = list(line = list(width = 0))
    )
    fig <- fig %>% layout(
      geo = g <- list(
        fitbounds = "locations",
        visible = FALSE,
        projection = list(type = "transverse mercator")
      ))
    fig <- fig %>% colorbar(title = metric)
    fig <- fig %>% layout(title = paste(violation, '(',year,')'))
    fig
    
  }
)

# Tab 1 CMA plot
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
      ggplot(aes(x = Value, y = reorder(Geography, Value))) +
      geom_bar(width = 0.5, stat = "identity") + # size may need changing
      labs(x = metric, y = 'Census Metropolitan Area (CMA)') +
      ggtitle(paste(year, violation))
    
    ggplotly(plot, tooltip="Value")
   }
)

# Helper function
get_dropdown_options <- function(col){
  unique(col) %>% map(function(val) list(label = val, value = val))
}

# Tab 1 Metric Dropdown
app$callback(
  output('metric_select', 'options'),
  list(input('crime-dashboard-tabs', 'value')),
  function(...){
    get_dropdown_options(DATA$Metric)
  }
)

# Tab 1 Violation Dropdown
app$callback(
  output('violation_select', 'options'),
  list(input('crime-dashboard-tabs', 'value')),
  function(...){
    get_dropdown_options(DATA$Violation.Description)
  }
)

# Tab 2 Multi Location Dropdown
app$callback(
    output('geo_multi_select', 'options'),
    list(input('geo_radio_button', 'value'),
         input('crime-dashboard-content', 'children')),
    function(geo_level, ...){
        df <- DATA %>%
            filter(Geo_Level == geo_level)
        get_dropdown_options(df$Geography)
    }
)

app$callback(
    output('crime_trends_plot', 'figure'),
    list(
        input('geo_multi_select', 'value'),
        input('geo_radio_button', 'value')
    ),
    function(geo_list, geo_level) {

        metric <- "Rate per 100,000 population"
        metric_name <- "Violations per 100k"
        
        categories <- c(
          'Violent Crimes' = 'Total violent Criminal Code violations', 
          'Property Crimes' = 'Total property crime violations',
          'Drug Crimes' =  'Total drug violations',
          'Other Criminal Code Violations' = 'Total other Criminal Code violations')
        
        df <- DATA %>%
            filter(Metric == metric) %>%
            filter(Geo_Level == geo_level) %>%  
            filter(Geography %in% geo_list) %>%
            filter(Violation.Description %in% categories)
        
        plot <- df %>%
          ggplot(aes(x = Year, y = Value, color = Geography)) +
          geom_line() +
          labs(y = metric) +
          facet_wrap(~Violation.Description, 
                     ncol=2, 
                     scales = "free"
                     )
        
        ggplotly(plot)
    }
)

# app$run_server(debug=FALSE) #(CAL: I HAD TO COMMENT OUT THE LINE BELOW FOR THIS TO WORK ON MY MACHINE)
app$run_server(host = '0.0.0.0', debug=FALSE)
