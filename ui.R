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
                            
                  )
    )
  )
)
