
<!-- README.md is generated from README.Rmd. Please edit that file -->

# reactRouter

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/reactRouter)](https://CRAN.R-project.org/package=reactRouter)
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

Install **reactRouter** with:

``` r
remotes::install_github("lgnbhl/reactRouter")
```

### More tutorials

Read the vignette
[here](https://lgnbhl.github.io/reactRouter/articles/introduction.html)
for detailed tutorials of **reactRouter** use cases with Quarto and R
Shiny.
