library(shiny)

ui <- fluidPage(
  reactRouter::HashRouter(
    reactRouter::Routes(
      reactRouter::Route(
        path = "/",
        element = div(reactRouter::Outlet()),
        reactRouter::Route(
          path = "products/:id",
          element = div(
            div(
              id = "matchFull",
              reactRouter::useMatch(
                tags$span(),
                pattern = "/products/:id"
              )
            ),
            div(
              id = "matchParams",
              reactRouter::useMatch(
                tags$span(),
                pattern = "/products/:id",
                selector = "params"
              )
            ),
            div(
              id = "matchPathname",
              reactRouter::useMatch(
                tags$span(),
                pattern = "/products/:id",
                selector = "pathname"
              )
            ),
            div(
              id = "noMatch",
              reactRouter::useMatch(
                tags$span(),
                pattern = "/other"
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
