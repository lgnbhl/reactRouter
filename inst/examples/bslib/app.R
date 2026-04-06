library(reactRouter)
library(bslib)
library(htmltools)
library(shiny)

Layout <- bslib::page_navbar(
  title = "reactRouter with bslib",
  nav_item(
    reactRouter::NavLink(
      "Home",
      to = "/",
      #reloadDocument = TRUE, # MANDATORY WITH R SHINY
      style = JS(
        '({isActive}) => { return isActive ? {color: "red", textDecoration: "none"} : {}; }'
      )
    )
  ),
  nav_item(
    reactRouter::NavLink(
      "Analysis",
      to = "/analysis",
      #reloadDocument = TRUE, # MANDATORY WITH R SHINY
      style = JS(
        '({isActive}) => { return isActive ? {color: "red", textDecoration: "none"} : {}; }'
      )
    )
  ),
  reactRouter::Outlet()
)

ui <- reactRouter::RouterProvider(
  reactRouter::Route(
    path = "/",
    element = Layout,
    reactRouter::Route(
      index = TRUE,
      element = div(
        tags$h3("Home page"),
        p("A basic example of reactRouter with bslib.")
      )
    ),
    reactRouter::Route(
      path = "analysis",
      element = "Content analysis"
    ),
    reactRouter::Route(path = "*", element = "Custom error 404")
  )
)

# htmltools::save_html(ui, "index.html")
htmltools::browsable(ui)
