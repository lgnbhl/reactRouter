# useRoutes() builds the route tree imperatively from inside a component,
# instead of declaring it as the value of createHashRouter()'s children.
#
# Two styles are shown below — pick whichever you prefer:
#   1. Pass Route() elements as children (R-idiomatic).
#   2. Pass a `routes` JS() expression with plain route objects (matches
#      the official React Router v7 docs).
#
# useRoutes() must be called inside a router. We mount RouterProvider with
# createHashRouter() and a single catch-all route whose element drives
# routing through useRoutes(). createHashRouter() is preferred over the
# legacy HashRouter() because it unlocks loaders, actions, and errorElement.

library(reactRouter)
library(htmltools)

# Style 1 — Route() children
app_with_route_children <- div(
  tags$nav(
    NavLink(to = "/",      "Home"), " | ",
    NavLink(to = "/about", "About")
  ),
  tags$hr(),
  useRoutes(
    Route(path = "/",      element = tags$h3("Home")),
    Route(path = "/about", element = tags$h3("About")),
    Route(path = "*",      element = tags$h3("Not found"))
  )
)

# Style 2 — plain object array via JS()
app_with_plain_routes <- div(
  tags$nav(
    NavLink(to = "/",      "Home"), " | ",
    NavLink(to = "/about", "About")
  ),
  tags$hr(),
  useRoutes(
    routes = JS("[
      { path: '/',      element: React.createElement('h3', null, 'Home (object route)') },
      { path: '/about', element: React.createElement('h3', null, 'About (object route)') },
      { path: '*',      element: React.createElement('h3', null, 'Not found') }
    ]")
  )
)

ui <- RouterProvider(
  router = createHashRouter(
    Route(
      path = "*",
      element = div(
        style = "max-width: 480px; margin: 0 auto; padding: 20px; font-family: system-ui;",
        tags$h2("useRoutes Example"),
        tags$h4("Style 1 — Route() children"),
        app_with_route_children,
        tags$hr(),
        tags$h4("Style 2 — plain object array"),
        app_with_plain_routes
      )
    )
  )
)

htmltools::browsable(ui)
