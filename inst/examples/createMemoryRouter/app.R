# Minimal example using createMemoryRouter() and createRoutesFromElements().
# This uses the data router API with in-memory routing: the browser URL is
# never read or modified, so it works on file:// (static HTML, Quarto).
# Demonstrates the `loader` argument with useLoaderData() to fetch and display data.
# Prefer createHashRouter() when you want the URL to reflect the current page.

library(reactRouter)
library(htmltools)

Home <- div(
  h2("Home"),
  p("Welcome to the Home page.")
)

About <- div(
  h2("About"),
  p("This page was loaded with data from a loader:"),
  tags$blockquote(useLoaderData(
    tags$span(),
    selector = "message"
  )),
  p(
    tags$small(
      "Loaded at: ",
      useLoaderData(tags$span(), selector = "timestamp")
    )
  )
)

NoMatch <- div(
  h2("404 - Not Found"),
  p(NavLink(to = "/", "Go back home"))
)

Layout <- div(
  tags$nav(
    tags$ul(
      tags$li(NavLink(to = "/", end = TRUE, "Home")),
      tags$li(NavLink(to = "/about", "About")),
      tags$li(NavLink(to = "/nothing-here", "Nothing Here"))
    )
  ),
  tags$hr(),
  Outlet()
)

ui <- createMemoryRouter(
  createRoutesFromElements(
    Route(
      path = "/",
      element = Layout,
      Route(index = TRUE, element = Home),
      Route(
        path = "about",
        loader = JS(
          "async () => {
            await new Promise(r => setTimeout(r, 500));
            return {
              message: 'Hello from the About loader!',
              timestamp: new Date().toLocaleTimeString()
            };
          }"
        ),
        element = About
      ),
      Route(path = "*", element = NoMatch)
    )
  )
)

# htmltools::save_html(ui, "index.html")
htmltools::browsable(ui)
