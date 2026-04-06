# Minimal example using MemoryRouter() as a static HTML page.
# MemoryRouter keeps routing state in memory and always starts at "/",
# making it ideal for static files (file://) where the real URL is not "/".
# BrowserRouter cannot be used here because it reads the real URL path on
# init, which on file:// is the file path (not "/"), causing a 404.
# For Shiny apps, prefer HashRouter().
# View with: htmltools::browsable(ui) or htmltools::save_html(ui, "index.html")

library(reactRouter)
library(htmltools)

Home <- div(
  h2("Home"),
  p("Welcome to the Home page.")
)

About <- div(
  h2("About"),
  p("This is the About page.")
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

ui <- MemoryRouter(
  Routes(
    Route(
      path = "/",
      element = Layout,
      Route(index = TRUE, element = Home),
      Route(path = "about", element = About),
      Route(path = "*", element = NoMatch)
    )
  )
)

# htmltools::save_html(ui, "index.html")
htmltools::browsable(ui)
