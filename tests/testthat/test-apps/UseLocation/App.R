library(shiny)

ui <- reactRouter::HashRouter(
  div(
    id = "locAll",
    reactRouter::useLocation(
      tags$span()
    )
  ),
  div(
    id = "locPathname",
    reactRouter::useLocation(
      tags$span(),
      selector = "pathname"
    )
  ),
  div(
    id = "locSearch",
    reactRouter::useLocation(
      tags$span(),
      selector = "search"
    )
  ),
  div(
    id = "locHash",
    reactRouter::useLocation(
      tags$span(),
      selector = "hash"
    )
  ),
  reactRouter::Routes(
    reactRouter::Route(
      path = "/*",
      element = div(tags$p("content"))
    )
  )
)

server <- function(input, output, session) {}

shinyApp(ui, server)
