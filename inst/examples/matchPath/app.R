# matchPath() tests a pathname against a pattern and, on match, returns
# the captured params plus matched / base pathnames. Useful in plain R
# code that needs to act on a known URL — e.g. precomputing whether a
# given path will hit a route, or extracting params outside a router.
#
# This example shows the pure-R behaviour at the console, plus a small
# Shiny app that uses matchPath() to build a status panel from the
# current useLocation() pathname.

library(reactRouter)
library(htmltools)

# --- Pure R usage ---------------------------------------------------------

str(matchPath("/users/:id",          "/users/42"))
str(matchPath("/users/:id/posts/:p", "/users/42/posts/abc"))
str(matchPath("/users/:id",          "/about"))                  # NULL
str(matchPath(list(path = "/users", end = FALSE), "/users/42"))  # prefix match

# --- Shiny demo -----------------------------------------------------------

Status <- useLocation(
  render = JS(sprintf(
    "loc => {
       const m = %s;
       const hit = m(loc.pathname);
       return hit
         ? React.createElement('p', null, 'Matched /users/:id with id = ' + hit.params.id)
         : React.createElement('p', { style: { color: 'gray' } }, 'No /users/:id match.');
     }",
    # Matcher is built once on the JS side from a pattern string. We could
    # also call `matchPath()` in R server logic for the equivalent result.
    "(p) => { const re = /^\\/users\\/([^/]+)\\/?$/; const m = re.exec(p); return m ? { params: { id: m[1] } } : null; }"
  ))
)

Layout <- div(
  style = "max-width: 540px; margin: 0 auto; padding: 20px; font-family: system-ui;",
  tags$h2("matchPath() Example"),
  tags$nav(tags$ul(
    tags$li(NavLink(to = "/", "Home")),
    tags$li(NavLink(to = "/users/42", "/users/42")),
    tags$li(NavLink(to = "/about", "/about"))
  )),
  Status,
  tags$hr(),
  Outlet()
)

ui <- RouterProvider(
  router = createHashRouter(
    Route(
      path = "/",
      element = Layout,
      Route(index = TRUE, element = tags$p("Try the links above.")),
      Route(path = "users/:id", element = useParams(tags$h3(), selector = "id")),
      Route(path = "about",     element = tags$h3("About"))
    )
  )
)

# htmltools::save_html(ui, "index.html")
htmltools::browsable(ui)
