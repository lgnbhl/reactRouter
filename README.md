
<!-- README.md is generated from README.Rmd. Please edit that file -->

# reactRouter <img src="man/figures/logo.png" align="right" height="138" />

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/reactRouter)](https://CRAN.R-project.org/package=reactRouter)
[![Grand
total](https://cranlogs.r-pkg.org/badges/grand-total/reactRouter)](https://cran.r-project.org/package=reactRouter)
[![R-CMD-check](https://github.com/lgnbhl/reactRouter/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/lgnbhl/reactRouter/actions/workflows/R-CMD-check.yaml)
[![](https://img.shields.io/badge/react--router--dom-7.14.0-blue.svg)](https://reactrouter.com)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Follow-E4405F?style=social&logo=linkedin)](https://www.linkedin.com/in/FelixLuginbuhl)
<!-- badges: end -->

The goal of **reactRouter** is to provide a wrapper around [React
Router](https://reactrouter.com).

### Usage

You can easily add URL pages in a Quarto document or R Shiny app like
so:

``` r
library(reactRouter)
library(htmltools)

RouterProvider(
  router = createHashRouter(
    Route(
      path = "/",
      element = div(
        NavLink(to = "/", "Main"), " | ",
        NavLink(to = "/analysis", "Analysis"), hr(),
        Outlet()
      ),
      Route(index = TRUE, element = "Main content"),
      Route(path = "analysis", element = "Analysis content")
    )
  )
)
```

### Install

``` r
#remotes::install_github("lgnbhl/reactRouter") # development version

install.packages("reactRouter")
```

### Resources

- [Package documentation](https://felixluginbuhl.com/reactRouter/)
- [Getting Started
  vignette](https://felixluginbuhl.com/reactRouter/articles/introduction.html)
- [All R
  examples](https://github.com/lgnbhl/reactRouter/tree/main/inst/examples)
- [Official Material UI
  docs](https://mui.com/material-ui/getting-started/)

### Contribute

Would you like to contribute to the package? Have a look at the current
[roadmap](https://github.com/users/lgnbhl/projects/2/views/1).
