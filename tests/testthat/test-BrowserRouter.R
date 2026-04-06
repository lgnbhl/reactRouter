test_that("BrowserRouter renders at root URL", {
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = testthat::test_path("test-apps", "BrowserRouter")
  )
  app$wait_for_idle()

  content <- app$get_text("#browserRouterContent")
  expect_true(grepl("BrowserRouter active", content))

  home_text <- app$get_text("#browserHome")
  expect_true(grepl("browser home", home_text))
})
