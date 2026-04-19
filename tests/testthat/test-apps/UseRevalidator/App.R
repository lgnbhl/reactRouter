library(shiny)

ui <- fluidPage(
  reactRouter::createHashRouter(
    reactRouter::createRoutesFromElements(
      reactRouter::Route(
        path = "/",
        loader = reactRouter::JS("async () => ({ time: Date.now() })"),
        element = div(
          div(
            id = "revalidatorState",
            reactRouter::useRevalidator(
              tags$span()
            )
          ),
          div(
            id = "revalidatorFull",
            reactRouter::useRevalidator(
              tags$span(),
              selector = NULL
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
