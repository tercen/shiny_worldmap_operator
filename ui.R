library(shiny)

shinyUI(fluidPage(
  
  titlePanel("World map"),
  
  sidebarPanel(
    sliderInput("plotWidth", "Plot width (px)", 200, 2000, 500),
    sliderInput("plotHeight", "Plot width (px)", 200, 2000, 1200)
  ),
  
  mainPanel(
    uiOutput("reacOut")
  )
  
))