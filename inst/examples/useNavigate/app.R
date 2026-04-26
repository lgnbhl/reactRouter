# useNavigate() returns an imperative navigate function.
# Use it to trigger navigation from arbitrary event handlers —
# outside of <Link> / <NavLink> — e.g. after a button click or
# once some async work has completed.
#
# Because the hook returns a function (not a value), the `render`
# form is the natural fit: `render = JS("nav => <...>")`.

library(reactRouter)
library(htmltools)

# render receives the navigate function:
#   nav("/path")       push a new entry
#   nav("/path", { replace: true })
#   nav(-1)            go back one entry
nav_buttons <- JS(
  "nav => React.createElement('div', null,
    React.createElement('button', { onClick: () => nav('/about') }, 'Go to About'),
    ' ',
    React.createElement('button', { onClick: () => nav('/contact') }, 'Go to Contact'),
    ' ',
    React.createElement('button', { onClick: () => nav(-1) }, 'Back')
  )"
)

Layout <- div(
  style = "max-width: 480px; margin: 0 auto; padding: 20px; font-family: system-ui;",
  tags$h2("useNavigate Example"),
  tags$p(
    style = "color: #555; font-size: 0.9em;",
    "The buttons below call ", tags$code("navigate()"),
    " directly — no ", tags$code("<Link>"), " needed."
  ),
  useNavigate(render = nav_buttons),
  tags$hr(),
  Outlet()
)

ui <- RouterProvider(
  router = createHashRouter(
    Route(
      path = "/",
      element = Layout,
      Route(index = TRUE, element = tags$h3("Home")),
      Route(path = "about", element = tags$h3("About")),
      Route(path = "contact", element = tags$h3("Contact"))
    )
  )
)

# htmltools::save_html(ui, "index.html")
htmltools::browsable(ui)
