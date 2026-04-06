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
              id = "hrefRelative",
              reactRouter::useHref(
                tags$span(),
                to = "../settings"
              )
            ),
            div(
              id = "hrefAbsolute",
              reactRouter::useHref(
                tags$span(),
                to = "/home"
              )
            ),
            div(
              id = "resolvedAll",
              reactRouter::useResolvedPath(
                tags$span(),
                to = "../settings"
              )
            ),
            div(
              id = "resolvedPathname",
              reactRouter::useResolvedPath(
                tags$span(),
                to = "../settings",
                selector = "pathname"
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
