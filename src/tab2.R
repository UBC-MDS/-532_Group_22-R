# author: Ifeanyi Anene and Cal Schafer 
# date: 2021-01-22
#"""
#Module to generate tab 1: Geographic Crime Comparisons
#"""

library(dash)
library(dashHtmlComponents)
library(devtools)
library(dashCoreComponents)
library(dashBootstrapComponents)
library(tidyverse)
library(ggplot2)
library(cowplot)


generate_layout <- function(){
#    """Generate tab 2 layout
#
#    Returns
#    -------
#    dbc.Container
#        Container with the html content of the page
#    """    
    
return(dbcContainer(
    list(
    
    ### 1st Row 
    dbcRow(
        list(
        ### 1st column
        dbcCol(
            list(
            dbcRow(
                list(
                    htmlDiv(
                        list(
                            "Select Province or CMA",
                            dccRadioItems(
                                id='geo_radio_button',
                                options=list(
                                    list('label' = 'Province', 'value' = 'PROVINCE'),
                                    list('label' = 'CMA', 'value' = 'CMA'),
                                ),
                                value='PROVINCE', 
                                labelStyle=list('margin-left' = '10px', 'margin-right' = '10px') # haven't changed syntax
                            )
                        ),
                        style=list("width"= "100%"),
                    )
                ),
            ),
            dbcRow(
                list(
                    htmlDiv(
                        list(
                            "Select Locations to Display",
                            dccDropdown(
                                id = 'geo_multi_select',
                                multi = TRUE,
                                value = ''
                            ),
                        ),
                        style=list("width" = "100%"),
                    )
                )
            )
        ),
        style=list('padding-left' = '2%'),
        width=3
        ),
        dbcCol(
            list(
            # GET SASHA TO HELP, BELOW IS PYTHON CODE
            #html.Iframe(
            #    id = 'crime_trends_plot',
            #    style = {'border-width': '0', 'width': '100%', 'height': '800px'}
            )
        ), 
        style=list('padding-left' = '2%'),
        )
    )
),
fluid=True) # SASHA - STILL NEEDED? 
)
}