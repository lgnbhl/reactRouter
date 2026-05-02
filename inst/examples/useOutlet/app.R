# useOutlet() returns the matched child route's element, or NULL if no
# child route is matched. Unlike the <Outlet/> component, this lets you
# branch on whether the user is on the parent route itself and render a
# fallback (e.g. a "pick something" hint) instead of a blank slot.

library(reactRouter)
library(htmltools)

# render receives the matched child element (or null on the index/parent
# route). Falling back to a hint keeps the layout from looking empty.
outlet_or_hint <- JS(
  "o => o || React.createElement(
    'p',
    { style: { color: '#888', fontStyle: 'italic' } },
    'Pick a section from the menu above to see its content here.'
  )"
)

Layout <- div(
  style = "max-width: 520px; margin: 0 auto; padding: 20px; font-family: system-ui;",
  tags$h2("useOutlet Example"),
  tags$p(
    style = "color: #555; font-size: 0.9em;",
    "The area below renders the matched child route, or a fallback when ",
    "you are on the parent route."
  ),
  tags$nav(tags$ul(
    tags$li(NavLink(to = "/", "Home (no child)")),
    tags$li(NavLink(to = "/news", "News")),
    tags$li(NavLink(to = "/about", "About"))
  )),
  tags$hr(),
  tags$section(
    style = "padding: 12px; border: 1px dashed #ccc; border-radius: 6px;",
    useOutlet(render = outlet_or_hint)
  )
)

ui <- RouterProvider(
  router = createHashRouter(
    Route(
      path = "/",
      element = Layout,
      Route(path = "news", element = tags$h3("Latest news")),
      Route(path = "about", element = tags$h3("About us"))
    )
  )
)

# htmltools::save_html(ui, "index.html")
htmltools::browsable(ui)
