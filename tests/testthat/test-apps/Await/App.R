library(shiny)

# Deferred loader: returns a fast value plus a promise that resolves shortly
# after route entry. Await() should first show the fallback then the resolved
# value. Children-mode Await wraps a useAsyncValue() to test that path too.
ui <- reactRouter::RouterProvider(
  router = reactRouter::createHashRouter(
    reactRouter::Route(
      path = "/",
      element = div(reactRouter::Outlet()),
      reactRouter::Route(
        path = "report",
        loader = reactRouter::JS(
          "async () => ({
             title: 'Q1',
             details: new Promise(r => setTimeout(
               () => r({ revenue: '$1.2M', users: 18430 }), 250
             ))
           })"
        ),
        element = div(
          div(
            id = "title",
            reactRouter::useLoaderData(tags$span(), selector = "title")
          ),
          # Target mode: selector pulls one field from the resolved value.
          div(
            id = "revenue",
            reactRouter::Await(
              tags$span(),
              resolveKey = "details",
              selector = "revenue",
              fallback = tags$em(id = "revenueFallback", "loading-revenue")
            )
          ),
          # render = JS(...) target mode: receives the full resolved value.
          div(
            id = "usersRender",
            reactRouter::Await(
              resolveKey = "details",
              render = reactRouter::JS("d => `${d.users} users`"),
              fallback = tags$em(id = "usersFallback", "loading-users")
            )
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {}

shinyApp(ui, server)
