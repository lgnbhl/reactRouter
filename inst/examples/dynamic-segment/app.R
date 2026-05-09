# Minimal dynamic-segment example.
# Demonstrates: createHashRouter() with a `:id` route param, useParams(),
#               NavLink, Outlet. Uses the default `reloadDocument = FALSE`
#               (the recommended setting — see vignette("routers")).
# For a richer dynamic-segment app with loaders, errorElements, charts, and
# data grids, see reactRouterExample("star-wars-explorer").

library(reactRouter)
library(htmltools)

ui <- RouterProvider(
  router = createHashRouter(
    Route(
      path = "/",
      element = div(
        h3("reactRouter — dynamic segments"),
        tags$nav(
          NavLink(to = "/project/1", "Project 1"), " | ",
          NavLink(to = "/project/2", "Project 2"), " | ",
          NavLink(to = "/project/3", "Project 3")
        ),
        tags$hr(),
        Outlet()
      ),
      Route(
        index = TRUE,
        element = p("Select a project above.")
      ),
      Route(
        path = "project/:id",
        element = div(
          h4("Project ", useParams(tags$strong(), selector = "id")),
          p("The route parameter `:id` is read with useParams().")
        )
      ),
      Route(path = "*", element = div(h4("Not found"), NavLink(to = "/", "Home")))
    )
  )
)

# htmltools::save_html(ui, "index.html")
htmltools::browsable(ui)
