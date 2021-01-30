# Canadian Crime Dashboard Reflection

Our dashboard is split into two tabs, which we can discuss individually, along with the experience of implementing the dashboard in R, rather than Python.

## Tab 1

### Widgets

We have four widgets that are in a partial state of completion.

- The first widget (Select Metric) is fully implemented.

- For the second widget (Select Violation), a user can select from a complete list of violation types. This is not our final implementation, as we actually want this widget to only display high-level crime types (e.g., all property crimes, all violent crimes). We intend that by selecting a value, a user would then have the option in the 3rd widget to select from lower-level crime types (e.g., homicides, assaults) that belong to the higher-level crime category picked in the 2nd widget.

- As explained above, our 3rd widget has not been implemented yet.

- The fourth widget (select a specific Year) has been implemented (an improvement since last week).

- One other comment is that for our first three dropdown widgets, the values inside are in a random order. It would be an nice enhancement to order them alphabetically.

### Visualizations

We have two visualizations to display in this tab.

- First is a Choropleth map for Canada and its provinces. This is partially implemented (an improvement since last week). The map displays but it's aspect ratio and layout could be improved, and it currently isn't connected to our widgets.

- The second visualization is a bar chart that displays what the widgets have selected, broken down by Census Metropolitan Area (CMA). The graph sorts from largest values to lowest (an improvement since last week).

There is room to improve the visual layout of our first tab, including some additional narrative text and bolding.


## Tab 2

### Widgets 

- The first widget (a radio button) for selecting the Provincial or CMA level has been implemented.

- The second widget (a dropdown component) that lets user select multiple locations (provinces, or CMAs) has been fully implemented.  

- The last widget that lets a user select a crime metric (e.g., incidents per 100k, % of incidents unfounded) has not been implemented yet. 


### Visualizations 

There are four plots on display in this tab. Each plot displays a metric (currently Criminal Incidents per 100,000 population) for different types of crimes in different geographical locations. 

Improvements here can include resizing the graphs a little smaller, removing the y-axis label and inserting it as part of a graph title. 


## Other Components

We have cleaned up the textual descriptions of much of our data (e.g., converting "Winnipeg, Manitoba [466062]" to "Winnipeg, Manitoba"). French names are not entirely loading correctly, which we could fix for the next milestone.


## Switching from Python to R

The initial approach we took was an attempt to port over our code from Python to R with mass copy and pasting with some replacement of basic syntax (e.g., "." to "$"). We found out that copying and pasting an entire "house" all at once would not work, and worse, would not give us helpful debugging tips. We ended up having to break down our coding to build one "room" at a time, testing that it would work, and then moving on to the next component (much like last week). Converting over from one language to another is not for the faint of heart.

## Feedback Reflection

We received our week 2 feedback from the TA, but have not received the optional feedback yet from another group. Notable comments were that it would be worthwhile to clean up some of the text descriptions of our data (almost entirely implemented) and that our bar chart should be in descending order of the metric value (implemented). None of the feedback really requires much of a change in our future planning for week 4.