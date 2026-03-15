# Minimal example using createHashRouter() and createRoutesFromElements()
# This uses the data router API instead of the component-based <HashRouter> + <Routes>.
# Run with: reactRouter::reactRouterExample("hash-router")

library(shiny)
library(reactRouter)

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
  p(
    Link(to = "/", "Go back home")
  )
)

Layout <- div(
  tags$nav(
    tags$ul(
      tags$li(Link(to = "/", "Home")),
      tags$li(Link(to = "/about", "About")),
      tags$li(Link(to = "/nothing-here", "Nothing Here"))
    )
  ),
  tags$hr(),
  Outlet()
)

ui <- createHashRouter(
  createRoutesFromElements(
    Route(
      path = "/",
      element = Layout,
      Route(index = TRUE, element = Home),
      Route(path = "about", element = About),
      Route(path = "*", element = NoMatch)
    )
  )
)

server <- function(input, output, session) {}

shinyApp(ui, server)
