# useBlocker() intercepts navigation when a condition is true.
# It exposes a state field: "unblocked" | "blocked" | "proceeding".
#
# In this example a checkbox marks the form as "dirty". Navigating away
# while dirty triggers the blocker and changes its state to "blocked".
#
# Note: to let the user confirm or cancel the blocked navigation, use
# BlockerProceedButton() and BlockerResetButton() (see companion buttons).

library(reactRouter)
library(htmltools)

# shouldBlock fires when moving between different pathnames
should_block <- JS(
  "({ currentLocation, nextLocation }) =>
    currentLocation.pathname !== nextLocation.pathname"
)

ui <- RouterProvider(
  Route(
    path = "/",
    element = div(
      style = "max-width: 480px; margin: 0 auto; padding: 20px; font-family: system-ui;",
      tags$h2("useBlocker Example"),
      tags$nav(tags$ul(
        tags$li(NavLink(to = "/",        "Home (blocks if dirty)")),
        tags$li(NavLink(to = "/clean",   "Clean page (no blocker)"))
      )),
      tags$hr(),
      Outlet()
    ),
    Route(
      index = TRUE,
      element = div(
        tags$h3("Home — with blocker"),
        tags$p(
          tags$strong("Blocker state: "),
          useBlocker(tags$code(), shouldBlock = should_block)
        ),
        tags$p(
          style = "color: #555; font-size: 0.9em;",
          "Click 'Clean page' in the nav above. The blocker state changes to ",
          tags$code('"blocked"'),
          " and navigation is intercepted.",
          tags$br(),
          "Use ",
          tags$code("BlockerProceedButton()"),
          " / ",
          tags$code("BlockerResetButton()"),
          " (coming next) to confirm or cancel."
        )
      )
    ),
    Route(
      path = "clean",
      element = div(
        tags$h3("Clean page"),
        tags$p("No blocker on this route. Navigate freely."),
        tags$p(
          tags$strong("Blocker state: "),
          useBlocker(tags$code(), shouldBlock = should_block)
        )
      )
    )
  )
)

# htmltools::save_html(ui, "index.html")
htmltools::browsable(ui)
