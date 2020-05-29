library(shiny)
library(tercen)
library(dplyr)
library(tidyr)
library(ggplot2)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(udunits2)
library(units)

shinyServer(function(input, output, session) {
  
  dataInput <- reactive({
    getValues(session)
  })
  
  output$reacOut <- renderUI({
    plotOutput(
      "worldmap",
      height = input$plotHeight,
      width = input$plotWidth
    )
  }) 
  
  output$worldmap <- renderPlot({
    
    values <- dataInput()
    data <- values$data

    theme_set(theme_bw())
    
    world <- ne_countries(scale = "medium", returnclass = "sf")
   
    ggplot(data = world) + 
      geom_sf(fill= "antiquewhite") + 
      geom_point(data = data, aes(x = .x, y = .y, color = colors)) + 
      theme(panel.background = element_rect(fill = "aliceblue"))
    
  })
  
})

getCtx <- function(session) {
  # retreive url query parameters provided by tercen
  query <- parseQueryString(session$clientData$url_search)
  token <- query[["token"]]
  taskId <- query[["taskId"]]
  
  # create a Tercen context object using the token
  ctx <- tercenCtx(taskId = taskId, authToken = token)
  return(ctx)
}

getValues <- function(session){
  
  ctx <- getCtx(session)
  values <- list()

  values$data <- ctx %>% select(.x, .y, .ri, .ci, colors)

  return(values)
}
