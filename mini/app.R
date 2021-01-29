library(dash)
library(dashHtmlComponents)
library(dashCoreComponents)
library(dashBootstrapComponents)
library(tidyverse)
library(ggplot2)
library(cowplot)
library(gapminder)
library(plotly)

source("src/tab1.R")

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
  
  generate_layout()
)

app$run_server(debug=T, suppress_callback_exceptions = TRUE)
