library(shiny)
library(leaflet)
library(RColorBrewer)
library(reshape2)

shinyServer(function(input, output, session) {
  
  # Reactive expression for the data subsetted to what the user selected
  filteredPesticides <- reactive({
    
    data <- PUR.c[PUR.c$acre_treated >= input$acres[1] &
            PUR.c$acre_treated <= input$acres[2] &
            PUR.c$lbs_chm_used >= input$pounds[1] &
            PUR.c$lbs_chm_used <= input$pounds[2]
          ,] #select all columns
    
    if(!is.null(input$county)){
      data <- data[data$county_name %in% input$county,]
    }
    
    if(!is.null(input$chemical)){
      data <- data[data$chem_name %in% input$chemical,]
    }
    
    data
  })
  
  #filtered asthma data
  filteredInhalers <- reactive({
    data <- fakeData[fakeData$lat >= input$range[1] & fakeData$lat <= input$range[2] &
                       fakeData$date >= input$dateRange[1] & fakeData$date <= input$dateRange[2]
                     ,]
    
    if(!is.null(input$person)) {
      data <- data[data$person %in% input$person,]
    }
    
    data
  })
  
  #update slider inputs when needed
  observe({
    updateSliderInput(session, "acres",
                      min=0,
                      max = max(PUR.c[PUR.c$chem_name==input$chemical, "acre_treated"]),
                      value = c(0,max(PUR.c[PUR.c$chem_name==input$chemical, "acre_treated"]))
                      )
    
    updateSliderInput(session, "pounds",
                      min=0,
                      max = round(max(PUR.c[PUR.c$chem_name==input$chemical, "lbs_chm_used"]),2),
                      value = c(0,round(max(PUR.c[PUR.c$chem_name==input$chemical, "lbs_chm_used"]),2))
    )
    
    #updateSelectInput(session, "chemical", choices = as.vector(unique(PUR.c$chem_name)) )
  })
  
  
  # This reactive expression represents the palette function,
  # which changes as the user makes selections in UI.
  colorpal <- reactive({
    colorNumeric("YlOrRd", c(0,filteredPesticides()$lbs_chm_used)) #add zero to this vector in case there is only one value
  })
  
  output$map <- renderLeaflet({
    # Use leaflet() here, and only include aspects of the map that
    # won't need to change dynamically (at least, not unless the
    # entire map is being torn down and recreated).
    leaflet(PUR.c) %>% addTiles(urlTemplate = "http://api.tiles.mapbox.com/v4/mapbox.light/{z}/{x}/{y}.png?access_token=pk.eyJ1Ijoiam9zaHBlcHBlciIsImEiOiJuTWdrY2k4In0.HCCXtgU04scrTB_-ON4kjA") %>%
      fitBounds(~min(long), ~min(lat), ~max(long), ~max(lat))
  })
  
  # Incremental changes to the map (in this case, replacing the
  # circles when a new color is chosen) should be performed in
  # an observer. Each independent set of things that can change
  # should be managed in its own observer.
  
  observe({
    pal <- colorpal()
    leafletProxy('map') %>% clearShapes() #remove shapes
    
    if(input$normalize==FALSE){
      radSize=filteredPesticides()$acre_treated*5
      }
    else{
      radSize <- filteredPesticides()$acre_treated/max(filteredPesticides()$acre_treated)*5000
    }
    
    #add inhaler markers
    leafletProxy("map", data = filteredInhalers()) %>%
      addCircles(radius = 200, weight = 0.2, color = "#397eb9",
                 group="inhalers",
                 fillColor = "#397eb9", fillOpacity = 0.7, popup = ~paste(person,"<br>",date)
      )
    
    #add pesticide markers
    leafletProxy('map', data = filteredPesticides()) %>%
      #clearShapes(group = "pesticides") %>%
      addCircles(radius = radSize, weight = 1, color = "#777777", fillOpacity = 0.6,
                 fillColor = ~pal(c(0, lbs_chm_used)),
                 group="pesticides",
                 popup = paste("<strong>Chemical :</strong>", filteredPesticides()$chem_name,"<br>",
                               "<strong>Acres Treated: </strong>",as.character(round(filteredPesticides()$acre_treated,1)),"<br>",
                               "<strong>Pounds Applied: </strong>",as.character(round(filteredPesticides()$lbs_chm_used,1))
                               )
      )
  })
  
  # Use a separate observer to recreate the legend as needed.
  observe({
    proxy <- leafletProxy("map", data = filteredPesticides())
    
    # Remove any existing legend, and only if the legend is
    # enabled, create a new one.
    proxy %>% clearControls()
    
    if (input$legend) {
      pal <- colorpal()
      proxy %>% addLegend(position = "bottomright",
                          pal = pal, values = ~c(0, lbs_chm_used), title="Pounds Applied"
      )
    }
  })
  
  observeEvent(input$map_marker_click, {
    
    leafletProxy("map", session) %>% removeShape(input$map_marker_click$id)
  })
  
  
})