library(shiny)

shinyUI(fluidPage(
  
  titlePanel("World map"),

  sidebarPanel(
    uiOutput("selectRCell"),
    uiOutput("selectCCell"),
    
    checkboxInput("logScale", "Log scale", value = FALSE),
    "NB: for negative values, the opposite of the log transformed absolute is computed"
  ),
  
  mainPanel(
    uiOutput("reacOut")
  )
  
))