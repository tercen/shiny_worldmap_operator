library(shiny)

shinyUI(fluidPage(
  
  titlePanel("World map"),

  mainPanel(
    uiOutput("reacOut")
  )
  
))