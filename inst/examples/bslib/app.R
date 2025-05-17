library(reactRouter)
library(bslib)
library(htmltools)
library(shiny)

ui <- reactRouter::HashRouter(
  bslib::page_navbar(
    title = "reactRouter with bslib",
    nav_item(tags$a("Home", href = "#/")),
    nav_item(tags$a("Analysis", href = "#/analysis")),
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

