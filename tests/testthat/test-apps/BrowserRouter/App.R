library(shiny)

ui <- reactRouter::BrowserRouter(
  div(id = "browserRouterContent", tags$p("BrowserRouter active")),
  reactRouter::Routes(
    reactRouter::Route(
      path = "/*",
      element = div(id = "browserHome", tags$p("browser home"))
    )
  )
)

server <- function(input, output, session) {}

shinyApp(ui, server)
