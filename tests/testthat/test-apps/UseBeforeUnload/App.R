library(shiny)

ui <- reactRouter::HashRouter(
  reactRouter::useBeforeUnload(
    reactRouter::JS("e => { window.beforeUnloadCalls = (window.beforeUnloadCalls || 0) + 1; }")
  ),
  reactRouter::Routes(
    reactRouter::Route(
      path = "/",
      element = div(tags$p("home"))
    )
  )
)

server <- function(input, output, session) {}

shinyApp(ui, server)
