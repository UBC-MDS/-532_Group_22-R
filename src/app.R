# author: Sasha Babicki, Ifeanyi Anene, and Cal Schafer 
# date: 2021-01-22

#Generate crime statistics dashboard with 2 tabs
#Usage: python src/app.py
#Source for code to create tabs: https://dash.plotly.com/dash-core-components/tabs

install.packages('dash')
install_github('facultyai/dash-bootstrap-components@r-release')

library(dash)
library(dashHtmlComponents)
library(devtools)
library(dashCoreComponents)
library(dashBootstrapComponents)
library(tidyverse)
library(ggplot2)


#source(tab1)
#source(tab2)

app <- Dash$new(external_stylesheets = dbcThemes$BOOTSTRAP)

#app.title = 'Canadian Crime Dashboard' WHERE DOES THIS GET USED? PYTHON
app$run_server(debug = T)

app$layout = htmlDiv(
    dccTabs(id='crime-dashboard-tabs', value='tab-1', children= list(
        dccTab(label='Geographic Crime Comparisons', value='tab-1'),
        dccTab(label='Crime Trends', value='tab-2')
        )
        ),
    htmlDiv(id='crime-dashboard-content')
)

app$callback(
    output('crime-dashboard-content', 'children'),
    params = list(input('crime-dashboard-tabs', 'value')),
    render_content <- function(tab){ 
    
    data = import_data()
    if(tab == 'tab-1') {
        return(htmlDiv(tab1$generate_layout())) }
    else if (tab == 'tab-2') {
        return(htmlDiv(tab2$generate_layout()))
    }
    }
        )

# Pull initial data for plots
import_data <- function() {
#    """Import data from file
#
#    Returns
#    -------
#    cleaned up df 
#    """

path <- "data/processed/DSCI532-CDN-CRIME-DATA.tsv"
data <- read_tsv(path)

### Data Wrangling 
data <- data %>% drop_na() 
# data$Year <- as.Date()
return(data)
}

DATA = import_data()

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
    
return(ggplotly(plot, tooltip = 'Value'))

}


# ##### IN PROGRESS
## https://gist.github.com/M1r1k/d5731bf39e1dfda5b53b4e4c560d968d#file-canada_provinces-geo-json
# import plotly.express as px
# import json
#
# @app.callback(
#     Output("choropleth", "figure"),
#     Input('crime-dashboard-tabs', 'value'))
# def display_choropleth(__):
#     with open("canada_provinces.geo.json") as f:
#         geojson = json.load(f)
#     df =  DATA[
#         (DATA['PROVINCE'] == "PROVINCE")
#     ]
#     df.replace(" \[.*\]", "", regex=True, inplace=True)
#     fig = px.choropleth(
#         df, geojson=geojson, color="VALUE",
#         locations="GEO", featureidkey="VALUE",
#         projection="mercator", range_color=[0, 6500])
#     #fig.update_geos(fitbounds="locations", visible=False)
#     fig.update_layout(margin={"r":0,"t":0,"l":0,"b":0})
#
#     return fig
# ##### END IN PROGRESS

@app.callback(
    Output('crime_trends_plot', 'srcDoc'),
    Input('geo_multi_select', 'value'),
    Input('geo_radio_button', 'value'))
def plot_alt1(geo_values, geo_level):
    
    # First time loading show message instead of displaying plot
    if geo_values == "":
    return '<h1>Please select a location from the menu on the left to generate plots</div>'


geo_list = list(geo_values)
metric = "Violations per 100k"
metric_name = "Violations per 100k"

df = DATA[
    (DATA['Metric'] == 'Rate per 100,000 population') &
        (DATA["Geo_Level"] == geo_level)
]
df = df[df["Geography"].isin(geo_list)]

category_dict = {
    'Violent Crimes' : 'Total violent Criminal Code violations [100]',
    'Property Crimes' : 'Total property crime violations [200]',
    'Drug Crimes' : 'Total drug violations [401]',
    'Other Criminal Code Violations' : 'Total other Criminal Code violations [300]'
}

plot_list = []

for title, description in category_dict.items():
    plot_list.append(
        alt.Chart(df[df["Violation Description"] == description], title = title).mark_line().encode(
            x = alt.X('Year'),
            y = alt.Y('Value', title = metric_name),
            color = "Geography").properties(height = 150, width = 300)
    )

chart = (plot_list[0] | plot_list[2]) & (plot_list[1] | plot_list[3])

return chart.to_html()

def get_dropdown_values(col):
    """Create CMA barplot
    
    Parameters
    -------
    String
        The column to get dropdown options / value for
    
    Returns
    -------
    [[String], String]
        List with two elements, options list and default value based on data
    """
df = DATA[col].unique()
return [[{"label": x, "value": x} for x in df], df[0]]

@app.callback(
    Output('metric_select', 'options'),
    Output('metric_select', 'value'),
    Output('violation_select', 'options'),
    Output('violation_select', 'value'),
    Input('crime-dashboard-tabs', 'value'))
def set_dropdown_values(__):
    """Set dropdown options for metrics, returns options list and default value for each output"""
dropdowns = ["Metric", "Violation Description"]
output = []
for i in dropdowns:
    output += get_dropdown_values(i)
return output

@app.callback(
    Output('geo_multi_select', 'options'),
    Input('crime-dashboard-tabs', 'value'),    
    Input('geo_radio_button', 'value'))
def set_dropdown_values(__, geo_level):
    """Set dropdown options for metrics, returns options list  for each output"""

df = DATA[DATA["Geo_Level"] == geo_level]
df = df["Geography"].unique()
return [{'label': city, 'value': city} for city in df]

if __name__ == '__main__':
    
    # Disable max rows for data sent to altair plots
    alt.data_transformers.disable_max_rows()

app.run_server(debug=True)