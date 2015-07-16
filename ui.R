library(shiny)
library(leaflet)
library(RColorBrewer)



#ui.R
shinyUI(
  bootstrapPage(
    tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
    leafletOutput("map", width = "100%", height = "100%"),
    absolutePanel(top = 10, right = 10,draggable=TRUE,
                  wellPanel(style = "background-color: #ffffff; width: 350px",
                            tabsetPanel(type = "tabs",
                                        tabPanel('General',br(),
                                                 dateRangeInput('dateRange',
                                                                label = 'Date range input: yyyy-mm-dd',
                                                                start = as.Date("2012-1-1"), end = as.Date("2013-12-31")
                                                 )
                                        ),
                                        tabPanel('Pesticides', br(),
                                          sliderInput("acres", "Acres Treated", 0, max(PUR.c$acre_treated),
                                                      value = c(0,max(PUR.c$acre_treated)), step = 5
                                          ),
                                          sliderInput("pounds", "Pounds Applied", 0, round(max(PUR.c$lbs_chm_used),1),
                                                      value = c(0, round(max(PUR.c$lbs_chm_used),1)), step=0.1
                                          ),
                                          selectizeInput('county', 'Filter by County', sort(countyList), multiple = TRUE),
                                          selectizeInput("chemical", "Chemical", sort(as.vector(unique(PUR.c$chem_name))), multiple = FALSE, selected="Chlorpyrifos"),
                                          checkboxInput("legend", "Show legend", TRUE),
                                          checkboxInput("normalize", "Normalize bubble size", FALSE)
                                        ),
                                        tabPanel('Inhalers',br(),
                                                 sliderInput("range", "Latitude", min(fakeData$lat), max(fakeData$lat),
                                                             value = range(fakeData$lat), step = 0.01
                                                 ),
                                                 selectizeInput("person", "Select Person",
                                                                unique(fakeData$person),
                                                                multiple=TRUE,
                                                                selected="Spectral"
                                                 )
                                        )
                            )
                  )
    )
  )
)