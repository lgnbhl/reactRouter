library(shiny)

# useBlocker renders "unblocked" by default (no navigation attempted).
# With shouldBlock = FALSE, navigation is never blocked.
ui <- reactRouter::RouterProvider(
  router = reactRouter::createHashRouter(
    reactRouter::Route(
      path = "/",
      element = div(
        div(
          id = "blockerState",
          reactRouter::useBlocker(
            tags$span(),
            selector = "state",
            shouldBlock = reactRouter::JS(
              "({ currentLocation, nextLocation }) =>
                currentLocation.pathname !== nextLocation.pathname"
            )
          )
        ),
        div(
          id = "blockerStateRender",
          reactRouter::useBlocker(
            render = reactRouter::JS("b => b.state"),
            shouldBlock = reactRouter::JS(
              "({ currentLocation, nextLocation }) =>
                currentLocation.pathname !== nextLocation.pathname"
            )
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
