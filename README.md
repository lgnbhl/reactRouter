
<!-- README.md is generated from README.Rmd. Please edit that file -->

# shinyReactRouter

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

The goal of **shinyReactRouter** is to provide a wrapper around [React
Router (v6)](https://reactrouter.com/6.30.0).

### Usage

You can now add URL pages like so:

``` r
library(shinyReactRouter)

HashRouter(
  NavLink(to = "/", "Main"),
  NavLink(to = "/analysis", "Analysis"),
  Routes(
    Route(path = "/", element = "Main content"),
    Route(path = "/analysis", element = "Analysis content")
  )
)
```

### Install

Install **shinyReactRouter** like so:

``` r
remotes::install_github("lgnbhl/shinyReactRouter")
```

### Usage with R Shiny

In order to render objects from the server, you should observe user
clicks on each page produced by `NavLink.shinyInput()` (learn more about
**shiny.react** `*.shinyInput` wrappers
[here](https://appsilon.github.io/shiny.react/articles/shiny-react.html#creating-input-wrappers)).

It is **strongly** recommended to reload the session using the
`observeEvent({})` function to ensure server objects renders properly
when users clicks on a new page.

``` r
# in the server
# reload session when user clicks on new paeg
observeEvent(c(input$page_1, input$page_2), {
  session$reload()
})
```

For simple apps, wrapping the server R code in `observe({})` also works.
But for more advanced apps it is recommended to reload the session.

Below a simple example using R Shiny:

``` r
library(shinyReactRouter)
library(shiny)
library(DT)

ui <- fluidPage(
  shinyReactRouter::HashRouter(
    titlePanel("shinyReactRouter"),
    sidebarLayout(
      sidebarPanel(
        shinyReactRouter::NavLink.shinyInput(
          inputId = "page_home",
          to = "/",
          style = JS('({isActive}) => { return isActive ? {color: "red", textDecoration:"none"} : {}; }'),
          "Home"),
        br(),
        shinyReactRouter::NavLink.shinyInput(
          inputId = "page_analysis",
          to = "/analysis",
          style = JS('({isActive}) => { return isActive ? {color: "red", textDecoration: "none"} : {}; }'),
          "Analysis"
        ),
        br(),
        shinyReactRouter::NavLink.shinyInput(
          inputId = "page_about",
          to = "/about",
          style = JS('({ isActive }) => { return isActive ? { color: "red", textDecoration: "none" } : {}; }'),
          "About"
        )
      ),
      mainPanel(
        shinyReactRouter::Routes(
          shinyReactRouter::Route(
            path = "/",
            element = div(
              tags$h1("Home page"),
              tags$h4("A basic example of shinyReactRouter."),
              uiOutput(outputId = "contentHome")
            )
          ),
          shinyReactRouter::Route(
            path = "/analysis",
            element = div(
              tags$h1("Analysis"),
              DT::DTOutput("table")
              )
          ),
          shinyReactRouter::Route(
            path = "/about",
            element = div(
              uiOutput(outputId = "contentAbout")
            )
          ),
          shinyReactRouter::Route(path = "*", element = div(tags$p("Error 404")))
        )
      )
    )
  )
)

server <- function(input, output, session) {
  
  # reload session when user clicks on new page
  # observeEvent(c(input$page_home, input$page_analysis, input$page_about), {
  #   session$reload()
  # })
  
  # all R code in an observer
  observe({
    output$contentHome <- renderUI({
      p("Content home")
    })
    output$table <- renderDT({
      data.frame(x = c(1, 2), y = c(3, 4))
    })
    output$contentAbout <- renderUI({
      div(
        tags$h1("About"),
        p("Content about")
      )
    })
  })
}

shinyApp(ui, server)
```

### Usage with MUI Material UI

Below an example using MUI Material UI components from the
**shinyMaterialUI** R package:

``` r
# remotes::install_github("lgnbhl/shinyMaterialUI")
library(shiny)
library(shinyMaterialUI)
library(shinyReactRouter)


ui <- shinyMaterialUIPage(
  shinyReactRouter::HashRouter(
    CssBaseline(
    Typography("shinyReactRouter with shinyMaterialUI", variant = "h5", m = 2),
    Stack(
      direction = "row", spacing = 2, p = 2,
      Paper(
        MenuList(
          shinyReactRouter::NavLink.shinyInput(
            inputId = "page_home",
            to = "/",
            style = JS('({isActive}) => { return isActive ? {color: "red", textDecoration:"none"} : { textDecoration: "none" }; }'),
            MenuItem(
              "home"
            )
          ),
          br(),
          shinyReactRouter::NavLink.shinyInput(
            inputId = "page_analysis",
            to = "/analysis",
            style = JS('({isActive}) => { return isActive ? {color: "red", textDecoration: "none"} : { textDecoration: "none" }; }'),
            MenuItem(
              "Analysis"
            )
          ),
          br(),
          shinyReactRouter::NavLink.shinyInput(
            inputId = "page_about",
            to = "/about",
            style = JS('({ isActive }) => { return isActive ? { color: "red", textDecoration: "none" } : { textDecoration: "none" }; }'),
            MenuItem(
              "About"
            )
          )
        )
      ),
      Box(
        shinyReactRouter::Routes(
          shinyReactRouter::Route(
            path = "/",
            element = div(
              tags$h1("Home page"),
              tags$h4("A basic example of shinyReactRouter with shinyMaterialUI."),
              uiOutput(outputId = "contentHome")
            )
          ),
          shinyReactRouter::Route(
            path = "/analysis",
            element = div(
              tags$h1("Analysis"),
              uiOutput(outputId = "contentAnalysis")
              )
          ),
          shinyReactRouter::Route(
            path = "/about",
            element = uiOutput(outputId = "contentAbout")
          ),
          shinyReactRouter::Route(path = "*", element = div(tags$p("Error 404")))
        )
      )
    )
    )
  )
)

server <- function(input, output, session) {
  
  # reload session when user clicks on new page
  # observeEvent(c(input$page_home, input$page_analysis, input$page_about), {
  #   session$reload()
  # })
  
  # all R code in an observer
  observe({ 
    output$contentHome <- renderUI({
      p("Content home")
    })
    output$contentAnalysis <- renderUI({
      p("Content analysis")
    })
    output$contentAbout <- renderUI({
      div(
        tags$h1("About"),
        p("Content about")
      )
    })
  })
}

shinyApp(ui, server)
```

### Usage with Quarto

Thanks to the client side routing provided by React Router, you can also
create multiple pages in your Quarto / Rmarkdown documents (as no server
is required).

TODO: create Quarto example.

``` r
library(shinyReactRouter)

HashRouter(
  NavLink(to = "/", "Main"),
  NavLink(to = "/analysis", "Analysis"),
  Routes(
    Route(path = "/", element = "Main content"),
    Route(path = "/analysis", element = "Analysis content")
  )
)
```

### Usage with Shiny modules

shinyReactRouter usage with shiny modules is not tested yet.

### Alternatives

- [shiny.router](https://appsilon.github.io/shiny.router/) implements a
  custom hash routing for shiny.
- [brochure](https://github.com/ColinFay/brochure) provide a mechanism
  for creating natively multi-page shiny applications (but is still
  WIP).

### More information

shinyReactRouter implements React Router
[v.6.30.0](https://reactrouter.com/6.30.0).

More info about how to use React Router can be found in the [official
website](https://reactrouter.com/6.30.0).
