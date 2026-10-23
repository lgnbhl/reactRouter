library(shiny)

ui <- reactRouter::HashRouter(
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
  div(
    id = "tagAll",
    reactRouter::useSearchParams(
      tags$span(),
      param = "tag"
    )
  ),
  div(
    id = "tagSingle",
    reactRouter::useSearchParams(
      tags$span(),
      param = "tag",
      single = TRUE
    )
  ),
  div(
    id = "allSingle",
    reactRouter::useSearchParams(
      tags$span(),
      single = TRUE
    )
  ),
  div(
    id = "tabDefault",
    reactRouter::useSearchParams(
      tags$span(),
      param = "tab",
      single = TRUE,
      defaultInit = list(tab = "overview")
    )
  ),
  div(
    id = "tabDefaultString",
    reactRouter::useSearchParams(
      tags$span(),
      param = "tab",
      single = TRUE,
      defaultInit = "tab=summary"
    )
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
