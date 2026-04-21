# useBlocker() intercepts navigation when a condition is true.
# It exposes a state field: "unblocked" | "blocked" | "proceeding".
#
# The render function receives the full blocker object, including
# b.proceed() and b.reset() methods. Wire these to onClick handlers
# to build a real confirm/cancel dialog — otherwise the blocker stays
# stuck in "blocked" and the user can never navigate or reset.

library(reactRouter)
library(htmltools)

# shouldBlock fires when moving between different pathnames
should_block <- JS(
  "({ currentLocation, nextLocation }) =>
    currentLocation.pathname !== nextLocation.pathname"
)

# render receives the full blocker object b:
#   b.state      — "unblocked" | "blocked" | "proceeding"
#   b.proceed()  — confirm navigation
#   b.reset()    — cancel and return to "unblocked"
blocker_ui <- JS(
  "b => {
    const state = React.createElement('code', null, b.state);
    if (b.state !== 'blocked') return state;
    return React.createElement(React.Fragment, null,
      state, ' — ',
      React.createElement('button', { onClick: () => b.proceed() }, 'Leave'),
      ' ',
      React.createElement('button', { onClick: () => b.reset() }, 'Stay')
    );
  }"
)

ui <- RouterProvider(
  router = createHashRouter(
    Route(
      path = "/",
      element = div(
        style = "max-width: 480px; margin: 0 auto; padding: 20px; font-family: system-ui;",
        tags$h2("useBlocker Example"),
        tags$nav(tags$ul(
          tags$li(NavLink(to = "/", "Home (blocks navigation)")),
          tags$li(NavLink(to = "/other", "Other page"))
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
            useBlocker(shouldBlock = should_block, render = blocker_ui)
          ),
          tags$p(
            style = "color: #555; font-size: 0.9em;",
            "Click 'Other page'. The state changes to ",
            tags$code('"blocked"'), " and two buttons appear.",
            tags$br(),
            tags$em("Leave"), " calls ", tags$code("b.proceed()"),
            " to confirm navigation; ",
            tags$em("Stay"), " calls ", tags$code("b.reset()"),
            " to cancel and return to ", tags$code('"unblocked"'), "."
          )
        )
      ),
      Route(
        path = "other",
        element = div(
          tags$h3("Other page"),
          tags$p("No blocker on this route. Navigate freely.")
        )
      )
    )
  )
)

# htmltools::save_html(ui, "index.html")
htmltools::browsable(ui)
