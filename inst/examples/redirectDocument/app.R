# redirectDocument() returns a JS loader that performs a full-page reload
# to the given URL — as opposed to redirect()'s client-side navigation.
# Use it when leaving the SPA entirely, e.g. to a server-rendered page
# or an external site, so the browser fully unloads the router.
#
# Compare:
#   /spa  --redirect-->          /home    (in-router; URL bar updates, no reload)
#   /docs --redirectDocument--> /static/  (browser-level navigation; reload)

library(reactRouter)
library(htmltools)

Layout <- div(
  style = "max-width: 540px; margin: 0 auto; padding: 20px; font-family: system-ui;",
  tags$h2("redirectDocument() Example"),
  tags$nav(tags$ul(
    tags$li(NavLink(to = "/", "Home")),
    tags$li(NavLink(to = "/external", "/external (full-page redirect to https://example.com)"))
  )),
  tags$p(
    style = "color: gray; font-size: 0.9em;",
    "Click /external to leave the SPA via a document-level redirect."
  ),
  tags$hr(),
  Outlet()
)

ui <- RouterProvider(
  router = createHashRouter(
    Route(
      path = "/",
      element = Layout,
      Route(index = TRUE, element = tags$h3("Home")),
      Route(
        path = "external",
        loader = redirectDocument("https://example.com"),
        element = NULL
      )
    )
  )
)

# htmltools::save_html(ui, "index.html")
htmltools::browsable(ui)
