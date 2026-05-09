# replaceResponse() returns a JS loader that performs a *replace* navigation.
# Same as redirect(), but the target URL replaces the current entry in
# the history stack instead of pushing a new one — ideal for legacy
# aliases that should not appear in the user's back-history.
#
# /legacy --replaceResponse--> /home   (back button skips /legacy)
# /old    --redirect-->         /home  (back button revisits /old, then redirects again)
#
# Renamed from replace() so it doesn't mask base::replace.

library(reactRouter)
library(htmltools)

Layout <- div(
  style = "max-width: 540px; margin: 0 auto; padding: 20px; font-family: system-ui;",
  tags$h2("replaceResponse() Example"),
  tags$nav(tags$ul(
    tags$li(NavLink(to = "/", "Home")),
    tags$li(NavLink(to = "/legacy", "/legacy (replaceResponse -> /home)")),
    tags$li(NavLink(to = "/old", "/old (redirect -> /home)"))
  )),
  tags$p(
    style = "color: gray; font-size: 0.9em;",
    "Open /legacy or /old, then press the browser Back button: ",
    "the replaceResponse() route is gone from history, the redirect() route is not."
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
      Route(path = "legacy", loader = replaceResponse("/"), element = NULL),
      Route(path = "old",    loader = redirect("/"),         element = NULL)
    )
  )
)

# htmltools::save_html(ui, "index.html")
htmltools::browsable(ui)
