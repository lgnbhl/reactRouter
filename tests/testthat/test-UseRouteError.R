test_that("useRouteError() renders error message", {
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = testthat::test_path("test-apps", "UseRouteError")
  )
  app$wait_for_idle()

  app_url <- app$get_url()

  app_error <- shinytest2::AppDriver$new(
    paste0(app_url, "/#/broken")
  )
  app_error$wait_for_idle()

  error_text <- app_error$get_text("#errorMsg")
  expect_equal(error_text, "test error message")
})
