library(shiny)

# Parent passes context = list(user = "Alice") to Outlet.
# Child reads it with useOutletContext().
ui <- fluidPage(
  reactRouter::createHashRouter(
    reactRouter::createRoutesFromElements(
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
            )
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {}

shinyApp(ui, server)
