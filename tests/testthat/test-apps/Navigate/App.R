library(shiny)

ui <- fluidPage(
  reactRouter::HashRouter(
    reactRouter::Routes(
      reactRouter::Route(
        path = "/",
        element = div(id = "homePage", tags$p("home"))
      ),
      reactRouter::Route(
        path = "old",
        element = reactRouter::Navigate(to = "/new", replace = TRUE)
      ),
      reactRouter::Route(
        path = "new",
        element = div(id = "newPage", tags$p("new page"))
      )
    )
  )
)

server <- function(input, output, session) {}

shinyApp(ui, server)
