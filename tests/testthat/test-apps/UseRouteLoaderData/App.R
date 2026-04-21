library(shiny)

ui <- reactRouter::RouterProvider(
  router = reactRouter::createHashRouter(
    reactRouter::Route(
      id = "root",
      path = "/",
      loader = reactRouter::JS(
        "async () => { return { title: 'Root Data', version: 1 }; }"
      ),
      element = div(
        reactRouter::Outlet()
      ),
      reactRouter::Route(
        path = "child",
        element = div(
          div(
            id = "rootDataAll",
            reactRouter::useRouteLoaderData(
              tags$span(),
              routeId = "root"
            )
          ),
          div(
            id = "rootDataTitle",
            reactRouter::useRouteLoaderData(
              tags$span(),
              routeId = "root",
              selector = "title"
            )
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {}

shinyApp(ui, server)
