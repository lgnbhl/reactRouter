# Minimal example showing useRouteError() which exposes useRouteError()
# useRouteError displays error information inside an errorElement

library(reactRouter)

ui <- RouterProvider(
  router = createMemoryRouter(
    Route(
      path = "/",
      element = div(
        tags$h2("useRouteError Example"),
        tags$nav(tags$ul(
          tags$li(NavLink(to = "/", "Home")),
          tags$li(NavLink(to = "/broken", "Broken Page"))
        )),
        tags$hr(),
        Outlet()
      ),
      Route(
        index = TRUE,
        element = div(tags$p("Home page - try the broken link!"))
      ),
      Route(
        path = "broken",
        loader = JS(
          "async () => { throw new Error('Something went wrong!'); }"
        ),
        element = div(tags$p("This should not render.")),
        errorElement = div(
          tags$h3(style = "color: red;", "Error!"),
          tags$p(
            "Error message: ",
            useRouteError(tags$span(), selector = "message")
          )
        )
      )
    )
  )
)

# htmltools::save_html(ui, "index.html")
htmltools::browsable(ui)
