library(shiny)

ui <- fluidPage(
  reactRouter::HashRouter(
    div(
      id = "navType",
      reactRouter::useNavigationType(
        tags$span()
      )
    ),
    reactRouter::Routes(
      reactRouter::Route(
        path = "/*",
        element = div(tags$p("content"))
      )
    )
  )
)

server <- function(input, output, session) {}

shinyApp(ui, server)
