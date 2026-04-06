# Minimal example using BrowserRouter.
# BrowserRouter uses the HTML5 history API (pushState, replaceState)
# so URLs look like normal paths (e.g. /about) instead of hash-based (#/about).
#
# IMPORTANT: Refreshing the page on any route other than "/" will break the app,
# because Shiny only serves the app at "/". The browser will request e.g. "/about"
# from the server, which Shiny doesn't handle, resulting in a 404.
# For Shiny apps, prefer HashRouter to avoid this issue.

library(shiny)
library(reactRouter)

Layout <- div(
  tags$nav(
    tags$ul(
      tags$li(Link(to = "/", "Home")),
      tags$li(Link(to = "/about", "About")),
      tags$li(Link(to = "/contact", "Contact"))
    )
  ),
  tags$hr(),
  Outlet()
)

Home <- div(
  tags$h2("Home"),
  tags$p("Welcome! This app uses BrowserRouter with clean URL paths."),
  tags$h3("Server-rendered content:"),
  textOutput("current_time"),
  verbatimTextOutput("session_info")
)

About <- div(

  tags$h2("About"),
  tags$p("BrowserRouter uses the HTML5 history API for navigation.")
)

Contact <- div(
  tags$h2("Contact"),
  tags$p("Reach us at hello@example.com"),
  tags$h3("Interactive input:"),
  textInput("user_name", "Your name:", placeholder = "Enter your name"),
  textOutput("greeting")
)

NoMatch <- div(
  tags$h2("404 - Page Not Found"),
  tags$p(Link(to = "/", "Go back home"))
)

ui <- BrowserRouter(
  div(
    tags$h1("BrowserRouter Example"),
    Routes(
      Route(
        path = "/",
        element = Layout,
        Route(index = TRUE, element = Home),
        Route(path = "about", element = About),
        Route(path = "contact", element = Contact),
        Route(path = "*", element = NoMatch)
      )
    )
  )
)

server <- function(input, output, session) {
  output$current_time <- renderText({
    invalidateLater(1000)
    paste("Current time:", Sys.time())
  })

  output$session_info <- renderPrint({
    cat("R version:", R.version.string, "\n")
    cat("Shiny version:", as.character(packageVersion("shiny")), "\n")
    cat("Session token:", session$token, "\n")
  })

  output$greeting <- renderText({
    req(input$user_name)
    paste0("Hello, ", input$user_name, "!")
  })
}

shinyApp(ui = ui, server = server)
