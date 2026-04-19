library(shiny)

# useBlocker renders "unblocked" by default (no navigation attempted).
# With shouldBlock = FALSE, navigation is never blocked.
ui <- fluidPage(
  reactRouter::createHashRouter(
    reactRouter::createRoutesFromElements(
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
          reactRouter::Outlet()
        ),
        reactRouter::Route(
          index = TRUE,
          element = div(tags$p("home"))
        )
      )
    )
  )
)

server <- function(input, output, session) {}

shinyApp(ui, server)
