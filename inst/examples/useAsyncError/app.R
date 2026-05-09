# useAsyncError() — reads the rejection reason of the closest <Await>.
# Pair it with an `errorElement` rendered via the children-mode Await:
# the deferred promise rejects, the errorElement subtree mounts, and
# useAsyncError() inside it surfaces the error message.

library(reactRouter)
library(htmltools)

ErrorBox <- div(
  style = "background:#fdecea; border:1px solid #f5c2c7; padding:12px; border-radius:6px;",
  tags$strong("Something went wrong: "),
  useAsyncError(tags$span(style = "color:#842029;"), selector = "message")
)

Layout <- div(
  style = "max-width: 560px; margin: 0 auto; padding: 20px; font-family: system-ui;",
  tags$h2("useAsyncError Example"),
  tags$nav(tags$ul(
    tags$li(NavLink(to = "/", "Home")),
    tags$li(NavLink(to = "/flaky", "Flaky endpoint (always fails)"))
  )),
  tags$hr(),
  Outlet()
)

ui <- RouterProvider(
  router = createMemoryRouter(
    Route(
      path = "/",
      element = Layout,
      Route(index = TRUE, element = tags$p("Open the flaky endpoint.")),
      Route(
        path = "flaky",
        loader = JS(
          "async () => ({
             payload: new Promise((_, reject) =>
               setTimeout(() => reject(new Error('upstream service unavailable')), 800)
             )
           })"
        ),
        element = div(
          tags$h3("Flaky Endpoint"),
          # Children-mode Await with an errorElement subtree.
          Await(
            resolveKey = "payload",
            fallback = tags$em(style = "color:gray;", "fetching…"),
            errorElement = ErrorBox,
            tags$p(useAsyncValue(tags$span()))
          )
        )
      )
    )
  )
)

# htmltools::save_html(ui, "index.html")
htmltools::browsable(ui)
