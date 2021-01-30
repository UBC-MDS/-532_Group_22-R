# author: Steffen Pentelow and Sasha Babicki
# date: 2021-01-22
#"""
#Module to generate tab 1: Geographic Crime Comparisons
#"""

library(dash)
library(dashHtmlComponents)
library(devtools)
library(dashCoreComponents)
library(dashBootstrapComponents)

generate_tab_1_layout <- function(){
#   """Generate tab 1 layout

#   Returns
#   -------
#   dbc.Container
#       Container with the html content of the page
#   """    
    #dropdown_height = 70    
    dbcContainer(list(
        dbcRow(list(
            dbcCol(list(
                dbcRow(list(
                    htmlDiv(list(
                        "Select Metric",
                        dccDropdown(id="metric_select" #optionHeight=dropdown_height
                                    )
                    ) #style=list("width" = "100%"), #JOEL USES MAX-WIDTH
                    )
                    )),
                    dbcRow(list(
                        htmlDiv(
                            list("Select Violation",
                                        dccDropdown(
                                            id="violation_select"
                                            #optionHeight=dropdown_height,
                                            
                                        )
                                 ) #style=list("width"= "100%"),
                            )
                        )
                        ),
                    dbcRow(list(
                        htmlDiv(list(
                                        "Select Violation Subcategory",
                                        dccDropdown(id="subviolation_select",
                                                    optionHeight=70)
                                )
                        ) #style=list("width" = "100%"),
                        )
                    )
                ), 
                #width="auto", 
                style=list('padding-left'= '2%')
                ), 
                
                # Column 2
                dbcCol(list(
                    dbcRow(list(
                            htmlDiv("Violation Subcategory by Province"),
                            htmlDiv(
                                list(
                                    dccGraph(id="choropleth")
                                    #htmlImg( src="https://i.pinimg.com/originals/27/8e/ef/278eefb576915d43e85b7a467d8f709a.jpg",
                                    #          width="100%",
                                    )
                                )
                            )
                        )
                    ), 
                    #width="auto", 
                    style=list('padding-left' = '2%')
                ),
                
            # Column 3
            dbcCol(list(
                dbcRow(list(
                    htmlDiv("Violation Subcategory by CMA"),
                    dccGraph(id='cma_barplot', style = list('width'= '100%', 'height'= '600px'))
                    )
                    )
                ),
                #width="auto", 
                style=list('padding-left' = '2%', 'padding-right' = '2%')
                )
            
            )
            )
        ),
        fluid = TRUE)
}
