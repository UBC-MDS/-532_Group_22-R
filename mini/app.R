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

app$callback(
  output = output(id='cma_barplot', property='figure'),
  params = list(input(id='metric_select', property='value')),
  function(x){
    ggplotly(
      ggplot(gapminder, aes(x = year)) + geom_histogram(bins=10)
    )
  }
)

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
      return(htmlDiv(generate_tab_1_layout()))
    }
  }
)

# CMA plot, tab1
app$callback(
  list(output('cma_barplot', 'children')),
  list(input('metric_select', 'value'), 
       input('violation_select', 'value')),
  function(metric, violation) {
    
    #"""Create CMA barplot
    #
    #Returns
    #-------
    #html
    #    altair plot in html format
    #"""
    
    df <- DATA %>%
      filter(metric == !!sym(metric)) %>%
      filter(`Violation Description` == !!sym(violation) %>%
               filter(Geo_Level == "CMA"))
    
    plot <- df %>%
      ggplot(aes(x = Value, y = Geography, tooltip = Value)) +
      geom_bar(width = 0.5) + # size may need changing
      labs(x = !!sym(metric), y = 'Census Metropolitan Area (CMA)') +
      ggtitle(!!sym(violation))
    
   ggplotly(plot, tooltip = 'Value')
})

app$callback(
  output = output(id='choropleth', property='figure'),
  params = list(input(id='metric_select', property='value')),
  function(x){
    metric <- "Rate per 100,000 population"
    violation <- "Total, all violations" # or "Total, all violations [0]" 
    year <- 2002
    
    provinces <- PROVINCES
    
    df <- DATA %>%
      filter(Geo_Level == "PROVINCE") %>% 
      filter(Metric == metric) %>%
      filter(Violation.Description == violation) %>%
      filter(Year == year)
    
    
    province_data <- left_join(provinces, df, by=c("NAME"="Geography"))
    
    num_colours <- 13
    bins <- round(seq(from=0, to=max(df$Value), length.out = num_colours), 0)
    
    # A few pallette options
    #pallete <- "inferno"
    pallete <- "RdYlBu"
    #pallete <- topo.colors(num_colours)
    #pallete <- colorRampPalette(c("#FF0000", "#000000", "#33FF00"))(num_colours)
    
    pal <- colorBin(pallete, domain = province_data$Value, bins = bins, reverse = TRUE)
    
    labels <- sprintf(
      "<strong>%s</strong><br/>%g per 100k population",
      province_data$NAME, province_data$Value
    ) %>% lapply(htmltools::HTML)
    
    # Code based on tutorial: https://rstudio.github.io/leaflet/choropleths.html
    #ggplotly() %>%
    not_working <- province_data %>%
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
          direction = "auto")) %>%
      addLegend(pal = pal, 
                values = ~Value, 
                opacity = 0.7, 
                title = violation,
                position = "bottomright")
    ggplotly(ggplot(gapminder, aes(x=year))+geom_histogram(bins=10))
    }
)

app$run_server(debug=T, suppress_callback_exceptions = TRUE)
