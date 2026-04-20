# shouldRevalidate Example
# Demonstrates: shouldRevalidate on a Route loader
# https://reactrouter.com/6.30.3/route/should-revalidate
#
# By default, React Router re-runs ALL loaders on every navigation.
# shouldRevalidate lets you skip re-runs when the data won't have changed,
# avoiding unnecessary work (network requests, DB queries, etc.).
#
# This example has a root loader that tracks how many times it has been called.
# shouldRevalidate tells React Router to only re-run it when navigating to
# Settings — not when switching between Home, Posts, and About.

library(reactRouter)
library(htmltools)

# Root loader: simulates an "expensive" config fetch.
# Uses a JS closure to count invocations across navigations.
root_loader <- JS(
  "
  (() => {
    let calls = 0;
    return () => {
      calls++;
      return { calls, fetchedAt: new Date().toLocaleTimeString() };
    };
  })()
"
)

# shouldRevalidate controls when the root loader re-runs after the initial load.
# Return true  → re-run the loader (revalidate)
# Return false → skip the loader (use cached data)
#
# Here: only revalidate when navigating TO /settings.
should_revalidate_root <- JS(
  "
  function({ nextUrl }) {
    return nextUrl.pathname === '/settings';
  }
"
)

ui <- RouterProvider(
  router = createMemoryRouter(
    Route(
      path = "/",
      loader = root_loader,
      shouldRevalidate = should_revalidate_root,
      element = div(
        style = "max-width: 600px; margin: 0 auto; padding: 20px; font-family: system-ui;",
        tags$h2("shouldRevalidate Example"),
        tags$p(
          style = "color: #555; font-size: 0.9em;",
          "The root loader runs once on initial load, then only again when navigating",
          " to Settings. Navigating between Home, Posts, and About skips the loader."
        ),
        # Counter badge — shows how many times the root loader has run
        tags$div(
          style = paste(
            "display: inline-flex; align-items: center; gap: 10px;",
            "background: #f0f7ff; border: 1px solid #90caf9;",
            "border-radius: 6px; padding: 10px 16px; margin-bottom: 16px;"
          ),
          tags$span(style = "color: #555;", "Root loader calls:"),
          useLoaderData(
            tags$strong(style = "font-size: 1.4em; color: #1565c0;"),
            selector = "calls"
          ),
          tags$span(
            style = "color: #aaa; font-size: 0.85em;",
            "\u2014 last at"
          ),
          useLoaderData(
            tags$span(style = "color: #aaa; font-size: 0.85em;"),
            selector = "fetchedAt"
          )
        ),
        # Navigation
        tags$nav(
          tags$ul(
            style = "list-style: none; display: flex; gap: 12px; padding: 0; margin: 0 0 12px;",
            tags$li(NavLink(to = "/", "Home")),
            tags$li(NavLink(to = "/posts", "Posts")),
            tags$li(NavLink(to = "/about", "About")),
            tags$li(NavLink(
              to = "/settings",
              style = "color: #b71c1c; font-weight: bold;",
              "Settings \u2192 triggers revalidation"
            ))
          )
        ),
        tags$hr(),
        Outlet()
      ),
      # Index route
      Route(
        index = TRUE,
        element = div(
          tags$h3("Home"),
          tags$p(
            "Click Posts or About \u2014 the counter above stays the same."
          ),
          tags$p("Click Settings \u2014 the counter increments.")
        )
      ),
      Route(
        path = "posts",
        element = div(
          tags$h3("Posts"),
          tags$p(
            style = "color: #2e7d32;",
            "\u2713 Root loader was skipped (shouldRevalidate returned false)."
          )
        )
      ),
      Route(
        path = "about",
        element = div(
          tags$h3("About"),
          tags$p(
            style = "color: #2e7d32;",
            "\u2713 Root loader was skipped (shouldRevalidate returned false)."
          )
        )
      ),
      Route(
        path = "settings",
        element = div(
          tags$h3("Settings"),
          tags$p(
            style = "color: #b71c1c;",
            "\u2191 Root loader RAN (shouldRevalidate returned true for this route)."
          )
        )
      )
    )
  )
)

# htmltools::save_html(ui, "index.html")
htmltools::browsable(ui)
