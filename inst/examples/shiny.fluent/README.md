# shiny.fluent example

This folder is a [`rhino`](https://appsilon.github.io/rhino/) project. The
top-level `app.R` is a 2-line stub (`rhino::app()`); the actual UI and server
code live under `app/main.R` and `app/view/`.

## Running it

```r
install.packages(c("rhino", "shiny.fluent", "echarts4r", "stringdist", "httr"))
shiny::runApp("inst/examples/shiny.fluent")
```

If `rhino` requires a JS/SCSS build first:

```r
rhino::build_js()
rhino::build_sass()
shiny::runApp("inst/examples/shiny.fluent")
```

## What it shows

A multi-page Dota 2 dashboard built with `shiny.fluent` UI components and
`reactRouter` for client-side routing inside a `rhino` project structure. See
the companion vignette `vignette("shiny.fluent", package = "reactRouter")`
for a full walkthrough.

## `manifest.json`

The bundled `manifest.json` is a snapshot and may reference an older path for
the React Router JS bundle. Before deploying to shinyapps.io / Posit Connect,
regenerate it:

```r
rsconnect::writeManifest(appDir = "inst/examples/shiny.fluent")
```

## Note on the router API

This example uses the **legacy component-based router**
(`HashRouter()` + `Routes()`) for compatibility with `rhino`'s `box` module
loading. For new projects, prefer the data router API
(`RouterProvider()` + `createHashRouter()`) — see
`vignette("routers", package = "reactRouter")`.
