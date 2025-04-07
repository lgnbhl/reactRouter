# Sys.setenv(
#   CHROMOTE_CHROME = "/Program Files (x86)/Microsoft/Edge/Application/msedge.exe"
# )

test_that("routes with HashRouter() work", {
  # Don't run these tests on the CRAN build servers
  skip_on_cran()

  # set up new app driver object
  app <- shinytest2::AppDriver$new(app_dir = testthat::test_path("test-apps", "HashRouter"))
  app$wait_for_idle()

  app_url <- app$get_url()

  app_home <- shinytest2::AppDriver$new(paste0(app_url, "/#"))
  app_page <- shinytest2::AppDriver$new(paste0(app_url, "/#/page"))

  values_home <- app_home$get_values()
  values_page <- app_page$get_values()

  expect_identical(names(values_home$input), c("NavLinkHome", "NavLinkPage"))
  expect_true(names(values_home$output) == "outputHome")
  expect_identical(as.character(values_home$output$outputHome$html), as.character(tags$p("home content")))
  expect_identical(names(values_page$input), c("NavLinkHome", "NavLinkPage"))
  expect_true(names(values_page$output) == "outputPage")
  expect_identical(as.character(values_page$output$outputPage$html), as.character(tags$p("page content")))
})
