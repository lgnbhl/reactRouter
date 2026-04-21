library(shiny)

ui <- reactRouter::MemoryRouter(
  initialEntries = list("/about"),
  reactRouter::Routes(
    reactRouter::Route(
      path = "/",
      element = div(id = "memHome", tags$p("memory home"))
    ),
    reactRouter::Route(
      path = "about",
      element = div(id = "memAbout", tags$p("memory about"))
    )
  )
)

server <- function(input, output, session) {}

shinyApp(ui, server)
