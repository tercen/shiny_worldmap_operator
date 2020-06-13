library(shiny)
library(tercen)
library(dplyr)
library(tidyr)
library(ggplot2)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(rgeos)

shinyServer(function(input, output, session) {
  
  dataInput <- reactive({
    getValues(session)
  })
  
  output$selectRCell <- renderUI({
    r.cells <- dataInput()$ri.names
    selectInput(inputId = "rcell", label = "Select row:", choices = r.cells)
  }) 
  
  output$selectCCell <- renderUI({
    c.cells <- dataInput()$ci.names
    selectInput(inputId = "ccell", label = "Select column:", choices = c.cells)
  }) 
  
  output$reacOut <- renderUI({
    plotOutput(
      "worldmap",
      height = 500,
      width = 800
    )
  }) 
  
  output$worldmap <- renderPlot({

    values <- dataInput()

    ri.id <- which(values$ri.names %in% input$rcell) - 1
    ci.id <- which(values$ci.names %in% input$ccell) - 1
    
    data <- values$data %>% subset(., .ri == ri.id & .ci == ci.id)

    theme_set(theme_bw())
    
    world <- ne_countries(scale = "medium", returnclass = "sf")
   
    baseplot <- ggplot(data = world) + 
      xlab("Longitude") + ylab ("Latitude") + labs(color = "Value") +
      geom_sf(fill= "antiquewhite") + 
      theme(panel.background = element_rect(fill = "aliceblue"))
  
    if(!is.na(data$colors[1])) {
      
      if(is.numeric(data$colors)) {
        
        if(input$logScale) {
          data$colors <- sign(data$colors) * log1p(abs(data$colors))
        }
        
        baseplot + geom_point(data = data, aes(x = .x, y = .y, color = colors)) +
          scale_colour_viridis_c()
        
      } else {
        
        baseplot + geom_point(data = data, aes(x = .x, y = .y, color = colors))
        
      }
      
      
    } else {
      
      baseplot + geom_point(data = data, aes(x = .x, y = .y))
      
    } 
    
  })
  
})

getCtx <- function(session) {
  # retreive url query parameters provided by tercen
  query <- parseQueryString(session$clientData$url_search)
  token <- query[["token"]]
  taskId <- query[["taskId"]]

  # create a Tercen context object using the token
  ctx <- tercenCtx(taskId = taskId, authToken = token)

  # options("tercen.workflowId" = "f81d245ef22a2ff192ed2533a6002ec3")
  # options("tercen.stepId"     = "74346a88-1df8-4311-bd0c-4775873af470")
  # ctx <- tercenCtx()
  
  return(ctx)
}

getValues <- function(session){

  ctx <- getCtx(session)
  values <- list()

  values$data <- ctx %>% select(.x, .y, .ri, .ci) %>% group_by(.ci, .ri)
  values$ri.names <- c(ctx$rselect()[[1]])
  values$ci.names <- c(ctx$cselect()[[1]])
  
  if(length(ctx$colors) == 0) {
    values$data$colors <- NA
  } else {
    values$data$colors <- ctx$select(ctx$colors)[[1]]
  }

  return(values)
}
