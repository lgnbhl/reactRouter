
<!-- README.md is generated from README.Rmd. Please edit that file -->

# reactRouter

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/reactRouter)](https://CRAN.R-project.org/package=reactRouter)
[![R-CMD-check](https://github.com/lgnbhl/reactRouter/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/lgnbhl/reactRouter/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of **reactRouter** is to provide a wrapper around [React Router
(v6)](https://reactrouter.com/6.30.0).

### Usage

You can now add URL pages like so:

``` r
library(reactRouter)

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

Install **reactRouter** like so:

``` r
remotes::install_github("lgnbhl/reactRouter")
```

### Usage with R Shiny

Below a simple example using R Shiny:

``` r
library(reactRouter)
library(shiny)
library(DT)

ui <- fluidPage(
  reactRouter::HashRouter(
    titlePanel("reactRouter"),
    sidebarLayout(
      sidebarPanel(
        reactRouter::NavLink(
          to = "/",
          style = JS('({isActive}) => { return isActive ? {color: "red", textDecoration:"none"} : {}; }'),
          "Home"),
        br(),
        reactRouter::NavLink(
          to = "/analysis",
          style = JS('({isActive}) => { return isActive ? {color: "red", textDecoration: "none"} : {}; }'),
          "Analysis"
        ),
        br(),
        reactRouter::NavLink(
          to = "/about",
          style = JS('({ isActive }) => { return isActive ? { color: "red", textDecoration: "none" } : {}; }'),
          "About"
        )
      ),
      mainPanel(
        reactRouter::Routes(
          reactRouter::Route(
            path = "/",
            element = div(
              tags$h1("Home page"),
              tags$h4("A basic example of reactRouter."),
              uiOutput(outputId = "contentHome")
            )
          ),
          reactRouter::Route(
            path = "/analysis",
            element = div(
              tags$h1("Analysis"),
              DT::DTOutput("table")
              )
          ),
          reactRouter::Route(
            path = "/about",
            element = div(
              uiOutput(outputId = "contentAbout")
            )
          ),
          reactRouter::Route(path = "*", element = div(tags$p("Error 404")))
        )
      )
    )
  )
)

server <- function(input, output, session) {
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
library(reactRouter)


ui <- reactRouter::HashRouter(
    CssBaseline(
    Typography("reactRouter with shinyMaterialUI", variant = "h5", m = 2),
    Stack(
      direction = "row", spacing = 2, p = 2,
      Paper(
        MenuList(
          reactRouter::NavLink(
            to = "/",
            style = JS('({isActive}) => { return isActive ? {color: "red", textDecoration:"none"} : { textDecoration: "none" }; }'),
            MenuItem(
              "home"
            )
          ),
          br(),
          reactRouter::NavLink(
            to = "/analysis",
            style = JS('({isActive}) => { return isActive ? {color: "red", textDecoration: "none"} : { textDecoration: "none" }; }'),
            MenuItem(
              "Analysis"
            )
          ),
          br(),
          reactRouter::NavLink(
            to = "/about",
            style = JS('({ isActive }) => { return isActive ? { color: "red", textDecoration: "none" } : { textDecoration: "none" }; }'),
            MenuItem(
              "About"
            )
          )
        )
      ),
      Box(
        reactRouter::Routes(
          reactRouter::Route(
            path = "/",
            element = div(
              tags$h1("Home page"),
              tags$h4("A basic example of reactRouter with shinyMaterialUI."),
              uiOutput(outputId = "contentHome")
            )
          ),
          reactRouter::Route(
            path = "/analysis",
            element = div(
              tags$h1("Analysis"),
              uiOutput(outputId = "contentAnalysis")
              )
          ),
          reactRouter::Route(
            path = "/about",
            element = uiOutput(outputId = "contentAbout")
          ),
          reactRouter::Route(path = "*", element = div(tags$p("Error 404")))
        )
      )
    )
  )
)

server <- function(input, output, session) {
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
}

shinyApp(ui, server)
```

### Propagation issue

It seems that {shiny} doesn’t show the content of a different route if
the structure of the `element` argument is identical in both routes. In
case the `element` structure is similar, you can refresh the session
each time the user click on a router link by observing the
`NavLink.shinyInput()` input in the session.

``` r
library(shiny)
library(reactRouter)

ui <- HashRouter(
  NavLink.shinyInput(inputId = "linkMain", to = "/", "Main"), br(),
  NavLink.shinyInput(inputId = "linkOther", to = "/other", "Other"),
  Routes(
    Route(
      path = "/", 
      element = div(uiOutput(outputId = "contentMain"))
    ),
    Route(
      path = "/other", 
      element = div(
        # A different HTML structure will make this route visible on user click
        #h1("Other"), # only a different structure makes Shiny execute / render this route
        uiOutput(outputId = "contentOther")
      )
    )
  )
)

server <- function(input, output, session) {
  # NOTE: please contact me if you know a way to refresh output content without reloading the session :)
  # reload session when user clicks on new page to refresh output content
  observeEvent(c(input$linkMain, input$linkOther), {
    session$reload()
  })
  output$contentMain <- renderUI( { p("Content home") } )
  output$contentOther <- renderUI( { p("New content") })
}

if (interactive()) {
  shinyApp(ui = ui, server = server)
}
```

### Usage with Quarto

Thanks to the client side routing provided by React Router, you can also
create multiple pages in your Quarto and Rmarkdown documents (as no
server is required).

TODO: create Quarto example.

``` r
library(reactRouter)

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

reactRouter usage with shiny modules is not tested yet.

### Alternatives

- [shiny.router](https://appsilon.github.io/shiny.router/) implements a
  custom hash routing for shiny.
- [brochure](https://github.com/ColinFay/brochure) provide a mechanism
  for creating natively multi-page shiny applications (but is still
  WIP).

### More information

reactRouter implements React Router
[v.6.30.0](https://reactrouter.com/6.30.0).

More info about how to use React Router can be found in the [official
website](https://reactrouter.com/6.30.0).
