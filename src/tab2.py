# author: Ifeanyi Anene and Cal Schafer 
# date: 2021-01-22
"""
Module to generate tab 1: Geographic Crime Comparisons
"""

import dash
import dash_html_components as html
import dash_core_components as dcc
from dash.dependencies import Input, Output
import numpy as np
import pandas as pd
import altair as alt
import datetime
import dash_bootstrap_components as dbc

def generate_layout():
    """Generate tab 2 layout

    Returns
    -------
    dbc.Container
        Container with the html content of the page
    """
    
    return dbc.Container([

        ### 1st Row 
        dbc.Row([
            ### 1st column
            dbc.Col([
                dbc.Row(
                    [
                        html.Div(
                            [
                                "Select Province or CMA",
                                dcc.RadioItems(
                                    id='geo_radio_button',
                                    options=[
                                        {'label': 'Province', 'value': 'PROVINCE'},
                                        {'label': 'CMA', 'value': 'CMA'},
                                    ],
                                    value='PROVINCE', 
                                    labelStyle={'margin-left': '10px', 'margin-right': '10px'}
                                )
                            ],
                            style={"width": "100%"},
                        )
                        
                    ],
                ),
                dbc.Row(
                    [
                        html.Div(
                            [
                                "Select Locations to Display",
                                dcc.Dropdown(
                                    id = 'geo_multi_select',
                                    multi = True,
                                    value = ''
                                ),
                            ],
                            style={"width": "100%"},
                        )
                    ]
                )
              ],
              style={'padding-left': '2%'},
              width=3
              ),
              dbc.Col([
                html.Iframe(
                    id = 'crime_trends_plot',
                    style = {'border-width': '0', 'width': '100%', 'height': '800px'}
                )
            ], 
            style={'padding-left': '2%'},
            )
        ])
    ],
    fluid=True)