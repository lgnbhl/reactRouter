# useInRouterContext() returns TRUE when the component is rendered inside
# a router (RouterProvider, HashRouter, MemoryRouter, ...) and FALSE
# otherwise. It is the safe gate to use in reusable components that may
# be mounted with or without a surrounding router — call it before any
# other router hook to avoid runtime errors.

library(reactRouter)
library(htmltools)

# A small "router status" panel reused in two contexts. Inside a router
# it should report TRUE; outside, FALSE.
# React renders bare booleans as nothing, so use `render` to coerce
# the value to a readable string before injecting it.
status_panel <- div(
  style = "padding: 8px 12px; border: 1px solid #ddd; border-radius: 4px;",
  tags$strong("Inside router context: "),
  useInRouterContext(render = JS("v => React.createElement('code', null, String(v))"))
)

# Render the same panel both inside and outside a router. The "inside"
# panel is mounted via RouterProvider(createHashRouter(...)) with a single
# catch-all route — createHashRouter() is preferred over the legacy
# HashRouter() because it unlocks loaders, actions, and errorElement.
inside_router <- RouterProvider(
  router = createHashRouter(
    Route(path = "*", element = status_panel)
  )
)

ui <- div(
  style = "max-width: 480px; margin: 0 auto; padding: 20px; font-family: system-ui;",
  tags$h2("useInRouterContext Example"),

  tags$h4("Outside any router"),
  status_panel,

  tags$h4("Inside a router"),
  inside_router
)

htmltools::browsable(ui)
