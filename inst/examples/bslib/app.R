library(reactRouter)
library(bslib)
library(htmltools)
library(shiny)

ui <- reactRouter::HashRouter(
  bslib::page_navbar(
    title = "reactRouter with bslib",
    nav_item(
      reactRouter::NavLink(
        "Home", 
        to = "/", 
        style = JS('({isActive}) => { return isActive ? {color: "red", textDecoration: "none"} : {}; }')
      )
    ),
    nav_item(
      reactRouter::NavLink(
        "Analysis", 
        to = "/analysis",
        style = JS('({isActive}) => { return isActive ? {color: "red", textDecoration: "none"} : {}; }')
      )
    ),
    reactRouter::Routes(
      reactRouter::Route(
        path = "/",
        element = div(
          tags$h3("Home page"),
          p("A basic example of reactRouter with bslib.")
        )
      ),
      reactRouter::Route(
        path = "/analysis",
        element = "Content analysis"
      ),
      reactRouter::Route(path = "*", element = "Custom error 404")
    )
  )
)

server <- function(input, output, session) {}

shinyApp(ui, server)
