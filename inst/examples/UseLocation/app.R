# Minimal example showing useLocation() which exposes useLocation()
# useLocation properties: pathname, search, hash, state, key

library(shiny)
library(reactRouter)

Layout <- div(
  h2("Location Example"),
  tags$nav(
    tags$ul(
      tags$li(NavLink(to = "/", "Home")),
      tags$li(NavLink(to = "/about", "About")),
      tags$li(NavLink(
        to = "/about?q=test#section",
        "About with query & hash"
      ))
    )
  ),
  tags$hr(),
  tags$h3("Pathname only:"),
  useLocation(tags$span(), selector = "pathname"),
  tags$h3("Search:"),
  useLocation(tags$span(), selector = "search"),
  tags$h3("Hash:"),
  useLocation(tags$span(), selector = "hash"),
  tags$hr(),
  Outlet()
)

ui <- RouterProvider(
  router = createHashRouter(
    Route(
      path = "/",
      element = Layout,
      Route(index = TRUE, element = div(tags$p("Home page"))),
      Route(path = "about", element = div(tags$p("About page")))
    )
  )
)

# htmltools::save_html(ui, "index.html")
htmltools::browsable(ui)
