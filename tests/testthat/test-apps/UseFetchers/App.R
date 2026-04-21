library(shiny)

ui <- reactRouter::RouterProvider(
  router = reactRouter::createHashRouter(
    reactRouter::Route(
      path = "/",
      element = div(
        div(
          id = "fetchersAll",
          reactRouter::useFetchers(
            tags$span()
          )
        ),
        reactRouter::Outlet()
      ),
      reactRouter::Route(
        index = TRUE,
        element = div(tags$p("home"))
      )
    )
  )
)

server <- function(input, output, session) {}

shinyApp(ui, server)
