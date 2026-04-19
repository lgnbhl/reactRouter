library(shiny)

# A fetcher-powered search: submit the Form to load filtered data
# without a full navigation. useFetcher() exposes state and data.
ui <- fluidPage(
  reactRouter::createHashRouter(
    reactRouter::createRoutesFromElements(
      reactRouter::Route(
        path = "/",
        element = div(
          div(
            id = "fetcherState",
            reactRouter::useFetcher(
              tags$span(),
              selector = "state"
            )
          ),
          div(
            id = "fetcherData",
            reactRouter::useFetcher(
              tags$span(),
              selector = "data.result"
            )
          ),
          reactRouter::Form(
            id = "fetchForm",
            method = "get",
            action = "/search",
            tags$input(type = "hidden", name = "q", value = "hello"),
            tags$button(type = "submit", "Fetch")
          ),
          reactRouter::Outlet()
        ),
        reactRouter::Route(
          path = "search",
          loader = reactRouter::JS(
            "({ request }) => {
              const q = new URL(request.url).searchParams.get('q') || '';
              return { result: 'found:' + q };
            }"
          ),
          element = div()
        )
      )
    )
  )
)

server <- function(input, output, session) {}

shinyApp(ui, server)
