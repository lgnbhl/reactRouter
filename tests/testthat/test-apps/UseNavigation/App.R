library(shiny)

ui <- fluidPage(
  reactRouter::createHashRouter(
    reactRouter::createRoutesFromElements(
      reactRouter::Route(
        path = "/",
        element = div(
          div(
            id = "navState",
            reactRouter::useNavigation(
              tags$span(),
              selector = "state"
            )
          ),
          div(
            id = "navAll",
            reactRouter::useNavigation(
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
)

server <- function(input, output, session) {}

shinyApp(ui, server)
