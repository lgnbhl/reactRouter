# Minimal example showing useParams() which exposes useParams()
# useParams extracts dynamic segments from the URL (e.g. :id)

library(reactRouter)

ui <- RouterProvider(
  router = createHashRouter(
    Route(
      path = "/",
      element = div(
        tags$h2("useParams Example"),
        tags$nav(tags$ul(
          tags$li(NavLink(to = "/", "Home")),
          tags$li(NavLink(to = "/user/42", "User 42")),
          tags$li(NavLink(to = "/user/99", "User 99"))
        )),
        tags$hr(),
        Outlet()
      ),
      Route(
        index = TRUE,
        element = div(tags$p("Select a user above."))
      ),
      Route(
        path = "user/:id",
        element = div(
          tags$h3("User Detail"),
          tags$p(
            "User ID: ",
            useParams(tags$span(), selector = "id")
          )
        )
      )
    )
  )
)

# htmltools::save_html(ui, "index.html")
htmltools::browsable(ui)
