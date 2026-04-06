library(shiny)

ui <- fluidPage(
  reactRouter::HashRouter(
    reactRouter::Link(to = "/about", id = "linkAbout", "Go to About"),
    reactRouter::Routes(
      reactRouter::Route(
        path = "/",
        element = div(id = "homePage", tags$p("home"))
      ),
      reactRouter::Route(
        path = "about",
        element = div(id = "aboutPage", tags$p("about content"))
      )
    )
  )
)

server <- function(input, output, session) {}

shinyApp(ui, server)
