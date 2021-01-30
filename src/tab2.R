# author: Ifeanyi Anene and Cal Schafer 
# date: 2021-01-22
#"""
#Module to generate tab 2: Geographic Crime Comparisons
#"""

library(dash)
library(dashHtmlComponents)
library(devtools)
library(dashCoreComponents)
library(dashBootstrapComponents)
library(tidyverse)
library(ggplot2)
library(cowplot)

#' Generate tab 2 layout
#'
#' @return dbcContainer Container with the html content of the page
generate_tab_2_layout <- function(){
    dbcContainer(list(
        dbcRow(list(
            # Column 1
            dbcCol(list(
                dbcRow(list(
                    htmlDiv(
                        list(
                            "Select Province or CMA",
                            dccRadioItems(
                                id='geo_radio_button',
                                options=list(
                                    list('label' = 'Province', 'value' = 'PROVINCE'),
                                    list('label' = 'CMA', 'value' = 'CMA')),
                                value='PROVINCE', 
                                labelStyle = list('margin-left' = '10px', 'margin-right' = '10px')
                                )
                        ),
                        style=list("width"= "100%")
                    )
                )),
                dbcRow(list(
                    htmlDiv(list(
                        "Select Locations to Display",
                        dccDropdown(id = 'geo_multi_select', 
                                    placeholder = "Please choose locations to display", 
                                    multi = TRUE)
                        ),
                        style=list("width" = "100%")
                        ))
                    )),
                style=list('padding-left' = '2%'),
                width=3),
            
            # Column 2
            dbcCol(list(
                htmlDiv("Crime Trends"),
                dccGraph(id="crime_trends_plot", 
                         style = list('width'= '100%', 'height'= '800px'))
            ),
            style=list('padding-left' = '2%'))
        ))
    ),
    fluid=TRUE
    ) 
}