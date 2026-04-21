library(shiny)

ui <- reactRouter::RouterProvider(
  router = reactRouter::createHashRouter(
    reactRouter::Route(
      path = "/",
      element = div(reactRouter::Outlet()),
      reactRouter::Route(
        path = "broken",
        loader = reactRouter::JS(
          "async () => { throw new Error('test error message'); }"
        ),
        element = div(tags$p("should not render")),
        errorElement = div(
          div(
            id = "errorMsg",
            reactRouter::useRouteError(
              tags$span(),
              selector = "message"
            )
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {}

shinyApp(ui, server)
