# useLinkClickHandler(to) returns a click handler that drives client-side
# navigation. Use it to make non-anchor elements behave like links —
# buttons, custom widgets, list rows — without giving up React Router's
# history-aware navigation.
#
# Because the hook returns a function, the `render` form is the natural
# fit. The handler can also be injected as a prop (e.g. `as = "onClick"`)
# of an existing element.

library(reactRouter)
library(htmltools)

# A "fake link" built out of a <span>: same navigation behaviour as <Link>,
# different markup.
fakeLink <- function(to, label) {
  useLinkClickHandler(
    to = to,
    render = JS(sprintf(
      "h => React.createElement(
         'span',
         { role: 'link', tabIndex: 0, onClick: h,
           style: {
             cursor: 'pointer',
             color: '#0a66c2',
             textDecoration: 'underline',
             marginRight: '12px'
           }
         },
         '%s'
       )",
      label
    ))
  )
}

Layout <- div(
  style = "max-width: 520px; margin: 0 auto; padding: 20px; font-family: system-ui;",
  tags$h2("useLinkClickHandler Example"),
  tags$p(
    style = "color: #555; font-size: 0.9em;",
    "These ", tags$code("<span>"), "s navigate via ",
    tags$code("useLinkClickHandler"), " — they are not ",
    tags$code("<a>"), " or ", tags$code("<Link>"), " elements."
  ),
  tags$nav(
    style = "margin-bottom: 16px;",
    fakeLink("/",        "Home"),
    fakeLink("/about",   "About"),
    fakeLink("/contact", "Contact")
  ),

  tags$h3("Inject the handler as a button's onClick"),
  tags$p(
    style = "color: #555; font-size: 0.9em;",
    "The button below uses ", tags$code("replace = TRUE"),
    " — clicking it replaces the current history entry instead of pushing a new one."
  ),
  useLinkClickHandler(
    to = "/about",
    replace = TRUE,
    into = tags$button("Replace history with /about"),
    as = "onClick"
  ),

  tags$hr(),
  Outlet()
)

ui <- RouterProvider(
  router = createHashRouter(
    Route(
      path = "/",
      element = Layout,
      Route(index = TRUE,     element = tags$h3("Home")),
      Route(path = "about",   element = tags$h3("About")),
      Route(path = "contact", element = tags$h3("Contact"))
    )
  )
)

# htmltools::save_html(ui, "index.html")
htmltools::browsable(ui)
