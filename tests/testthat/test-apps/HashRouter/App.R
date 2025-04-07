library(shiny)

ui <- fluidPage(
  shinyReactRouter::HashRouter(
    shinyReactRouter::NavLink.shinyInput(
      inputId = "NavLinkHome",
      to = "/",
      "Home"
    ),
    div(),
    shinyReactRouter::NavLink.shinyInput(
      inputId = "NavLinkPage",
      to = "page",
      "Page"
    ),
    hr(),
    shinyReactRouter::Routes(
      shinyReactRouter::Route(
        path = "/",
        element = div(
          uiOutput(outputId = "outputHome")
        )
      ),
      shinyReactRouter::Route(
        path = "page",
        element = div(
          uiOutput(outputId = "outputPage")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  # update session when clicking on specific navLink
  # session$reload() is the equivalent of hitting the browser's Reload button.
  observeEvent(input$NavLinkHome, {
    session$reload()
  })
  observeEvent(input$NavLinkPage, {
    session$reload()
  })
  output$outputHome <- renderUI({
    p("home content")
  })
  output$outputPage <- renderUI({
    p("page content")
  })
  # observe({
  #   # print full URL hash
  #   client_data <- reactiveValuesToList(session$clientData)
  #   url_hostname <- client_data$url_hostname
  #   url_port <- client_data$url_port
  #   url_hash <- client_data$url_hash
  #   print(paste0(url_hostname, ":", url_port, "/", url_hash))
  # })
}

shinyApp(ui, server)
