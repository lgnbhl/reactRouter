# Sys.setenv(
#   CHROMOTE_CHROME = "/Program Files (x86)/Microsoft/Edge/Application/msedge.exe"
# )

test_that("routes with HashRouter() work", {
  # Don't run these tests on the CRAN build servers
  skip_on_cran()

  # set up new app driver object
  app <- shinytest2::AppDriver$new(app_dir = testthat::test_path("test-apps", "HashRouter"))
  app$wait_for_idle()

  app$get_js("window.location.hash = '#/'")
  app$wait_for_idle()
  values_home <- app$get_values()

  app$get_js("window.location.hash = '#/page'")
  app$wait_for_idle()
  values_page <- app$get_values()

  expect_identical(names(values_home$input), c("NavLinkHome", "NavLinkPage"))
  expect_true("outputHome" %in% names(values_home$output))
  expect_identical(as.character(values_home$output$outputHome$html), as.character(tags$p("home content")))
  expect_identical(names(values_page$input), c("NavLinkHome", "NavLinkPage"))
  expect_true("outputPage" %in% names(values_page$output))
  expect_identical(as.character(values_page$output$outputPage$html), as.character(tags$p("page content")))
})
