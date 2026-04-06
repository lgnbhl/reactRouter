library(shiny)

ui <- fluidPage(
  reactRouter::HashRouter(
    div(
      id = "allParams",
      reactRouter::useSearchParams(
        tags$span()
      )
    ),
    div(
      id = "colorParam",
      reactRouter::useSearchParams(
        tags$span(),
        param = "color"
      )
    ),
    reactRouter::Routes(
      reactRouter::Route(
        path = "/",
        element = div(tags$p("home"))
      )
    )
  )
)

server <- function(input, output, session) {}

shinyApp(ui, server)
