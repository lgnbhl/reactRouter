
<!-- README.md is generated from README.Rmd. Please edit that file -->

# reactRouter <img src="man/figures/logo.png" align="right" height="138" />

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/reactRouter)](https://CRAN.R-project.org/package=reactRouter)
[![Grand
total](https://cranlogs.r-pkg.org/badges/grand-total/reactRouter)](https://cran.r-project.org/package=reactRouter)
[![R-CMD-check](https://github.com/lgnbhl/reactRouter/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/lgnbhl/reactRouter/actions/workflows/R-CMD-check.yaml)
[![](https://img.shields.io/badge/react--router--dom-6.30.0-blue.svg)](https://reactrouter.com/6.30.0)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Follow-E4405F?style=social&logo=linkedin)](https://www.linkedin.com/in/FelixLuginbuhl)
<!-- badges: end -->

The goal of **reactRouter** is to provide a wrapper around [React Router
(v6)](https://reactrouter.com/6.30.0).

### Usage

You can easily add URL pages in Quarto document or R shiny like so:

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

``` r
#remotes::install_github("lgnbhl/reactRouter") # development version

install.packages("reactRouter")
```

### Example

Get started with a showcase example:

``` r
# print all examples available: reactRouterExample()
reactRouterExample("basic")
```

Read the vignette
[here](https://felixluginbuhl.com/reactRouter/articles/introduction.html)
for detailed use cases with Quarto and R Shiny.

### Contribute

Would you like to contribute to the package? Have a look at the current
[roadmap](https://github.com/users/lgnbhl/projects/2/views/1).
