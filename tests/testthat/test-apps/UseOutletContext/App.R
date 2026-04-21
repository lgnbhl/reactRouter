library(shiny)

# Parent passes context = list(user = "Alice") to Outlet.
# Child reads it with useOutletContext().
ui <- reactRouter::RouterProvider(
  router = reactRouter::createHashRouter(
    reactRouter::Route(
      path = "/",
      element = div(
        reactRouter::Outlet(context = list(user = "Alice", role = "admin"))
      ),
      reactRouter::Route(
        index = TRUE,
        element = div(
          div(
            id = "contextUser",
            reactRouter::useOutletContext(
              tags$span(),
              selector = "user"
            )
          ),
          div(
            id = "contextRole",
            reactRouter::useOutletContext(
              tags$span(),
              selector = "role"
            )
          ),
          div(
            id = "contextAll",
            reactRouter::useOutletContext(
              tags$span()
            )
          ),
          div(
            id = "contextRender",
            reactRouter::useOutletContext(
              render = reactRouter::JS("c => `${c.user} (${c.role})`")
            )
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {}

shinyApp(ui, server)
