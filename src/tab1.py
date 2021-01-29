# author: Steffen Pentelow and Sasha Babicki
# date: 2021-01-22
"""
Module to generate tab 1: Geographic Crime Comparisons
"""

import dash
import dash_html_components as html
import dash_core_components as dcc
from dash.dependencies import Input, Output
import dash_bootstrap_components as dbc

def generate_layout():
    """Generate tab 1 layout

    Returns
    -------
    dbc.Container
        Container with the html content of the page
    """
    
    dropdown_height = 70
    
    return dbc.Container(
        [
            dbc.Row(
                [
                    # Column 1
                    dbc.Col(
                        [
                            dbc.Row(
                                [
                                    html.Div(
                                        [
                                            "Select Metric",
                                            dcc.Dropdown(
                                                id="metric_select",
                                                optionHeight=dropdown_height,
                                            ),
                                        ],
                                        style={"width": "100%"},
                                    ),
                                ]
                            ),
                            dbc.Row(
                                [
                                    html.Div(
                                        [
                                            "Select Violation",
                                            dcc.Dropdown(
                                                id="violation_select",
                                                optionHeight=dropdown_height,
                                            ),
                                        ],
                                        style={"width": "100%"},
                                    ),
                                ]
                            ),
                            dbc.Row(
                                [
                                    html.Div(
                                        [
                                            "Select Violation Subcategory",
                                            dcc.Dropdown(
                                                id="subviolation_select",
                                                options=[
                                                    {
                                                        "label": "Not Implemented Yet",
                                                        "value": "Dummy",
                                                    }
                                                ],
                                                optionHeight=dropdown_height,
                                            ),
                                        ],
                                        style={"width": "100%"},
                                    ),
                                ]
                            )
                        ],
                        style={'padding-left': '2%'}
                    ),
                    
                    # Column 2
                    dbc.Col(
                        dbc.Row(
                            [
                                html.Div("Violation Subcategory by Province"),
                                html.Div(
                                    [
                                        #dcc.Graph(id="choropleth"),
                                        html.Img( src="https://i.pinimg.com/originals/27/8e/ef/278eefb576915d43e85b7a467d8f709a.jpg",
                                            width="100%",
                                        )
                                    ]
                                ),
                            ]
                        ),
                        style={'padding-left': '2%'}
                    ),
                    
                    # Column 3
                    dbc.Col(
                        dbc.Row(
                            [
                                html.Div("Violation Subcategory by CMA"),
                                html.Iframe(
                                    id='cma_barplot',
                                    style={'border-width': '0', 'width': '100%', 'height': '600px'}
                                )
                            ]
                        ),
                        width="auto",
                        style={'padding-left': '2%', 'padding-right': '2%'}
                    ),
                ]
            )
        ], 
        fluid=True
    )