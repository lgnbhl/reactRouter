# generatePath() builds a concrete URL from a path *pattern* and a
# named list of params. Use it to construct Link `to` values from data
# without hand-pasting strings — the same way React Router's
# generatePath() is used in JS.
#
# Pattern syntax: ":param" for required segments, ":param?" for optional
# ones, "*" for splats.

library(reactRouter)
library(htmltools)

people <- list(
  list(id = 1, name = "Luke"),
  list(id = 2, name = "Leia"),
  list(id = 4, name = "Vader")
)

Layout <- div(
  style = "max-width: 540px; margin: 0 auto; padding: 20px; font-family: system-ui;",
  tags$h2("generatePath() Example"),
  tags$p("Each link below is built with generatePath('/people/:id', list(id = ...))."),
  tags$ul(
    lapply(people, function(p) {
      tags$li(NavLink(to = generatePath("/people/:id", list(id = p$id)), p$name))
    })
  ),
  tags$hr(),
  Outlet()
)

ui <- RouterProvider(
  router = createHashRouter(
    Route(
      path = "/",
      element = Layout,
      Route(index = TRUE, element = tags$p("Pick a person.")),
      Route(
        path = "people/:id",
        element = useParams(tags$h3(), selector = "id")
      )
    )
  )
)

# htmltools::save_html(ui, "index.html")
htmltools::browsable(ui)
