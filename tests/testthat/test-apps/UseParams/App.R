library(shiny)

ui <- reactRouter::RouterProvider(
  router = reactRouter::createHashRouter(
    reactRouter::Route(
      path = "/",
      element = div(
        reactRouter::Outlet()
      ),
      reactRouter::Route(
        path = "user/:id",
        element = div(
          div(
            id = "paramId",
            reactRouter::useParams(
              tags$span(),
              selector = "id"
            )
          ),
          div(
            id = "paramAll",
            reactRouter::useParams(
              tags$span()
            )
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {}

shinyApp(ui, server)
