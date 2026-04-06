library(shiny)

ui <- fluidPage(
  reactRouter::createHashRouter(
    reactRouter::createRoutesFromElements(
      reactRouter::Route(
        path = "/",
        element = div(reactRouter::Outlet()),
        reactRouter::Route(
          path = "data",
          loader = reactRouter::JS(
            "async () => { return { name: 'Alice', age: 30 }; }"
          ),
          element = div(
            div(
              id = "loaderAll",
              reactRouter::useLoaderData(
                tags$span()
              )
            ),
            div(
              id = "loaderName",
              reactRouter::useLoaderData(
                tags$span(),
                selector = "name"
              )
            ),
            div(
              id = "loaderAge",
              reactRouter::useLoaderData(
                tags$span(),
                selector = "age"
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
