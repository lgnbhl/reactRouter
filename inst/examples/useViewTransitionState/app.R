# useViewTransitionState(to) returns TRUE while a View Transitions API
# navigation toward `to` is in progress. Pair it with the `viewTransition`
# prop on <Link> / <NavLink> to drive transition-aware styling — e.g. a
# pulsing label on the link that just got clicked.
#
# Note: requires a browser that supports the View Transitions API
# (Chromium-based browsers and recent Safari).

library(reactRouter)
library(htmltools)

# Tiny helper: NavLink with viewTransition enabled, that bolds + tints itself
# while a transition toward its target is in flight.
animatedLink <- function(to, label) {
  useViewTransitionState(
    to = to,
    render = JS(sprintf(
      "isPending => React.createElement(
         window.jsmodule['react-router-dom'].NavLink,
         { to: '%s', viewTransition: true,
           style: {
             fontWeight: isPending ? 'bold' : 'normal',
             color:      isPending ? '#0a66c2' : 'inherit',
             marginRight: '12px'
           }
         },
         '%s'
       )",
      to, label
    ))
  )
}

Layout <- div(
  style = "max-width: 520px; margin: 0 auto; padding: 20px; font-family: system-ui;",
  tags$h2("useViewTransitionState Example"),
  tags$p(
    style = "color: #555; font-size: 0.9em;",
    "Click a link below — the link to the page being transitioned to is ",
    "briefly bolded and tinted while the transition runs."
  ),
  tags$nav(
    style = "margin-bottom: 16px;",
    animatedLink("/",       "Home"),
    animatedLink("/about",  "About"),
    animatedLink("/contact", "Contact")
  ),
  tags$hr(),
  Outlet()
)

ui <- RouterProvider(
  router = createHashRouter(
    Route(
      path = "/",
      element = Layout,
      Route(index = TRUE,    element = tags$h3("Home")),
      Route(path = "about",  element = tags$h3("About")),
      Route(path = "contact", element = tags$h3("Contact"))
    )
  )
)

# htmltools::save_html(ui, "index.html")
htmltools::browsable(ui)
