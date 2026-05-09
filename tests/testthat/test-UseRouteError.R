test_that("useRouteError() renders error message", {
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = testthat::test_path("test-apps", "UseRouteError")
  )
  app$wait_for_idle()

  app$get_js("window.location.hash = '#/broken'")
  app$wait_for_idle()

  error_text <- app$get_text("#errorMsg")
  expect_equal(error_text, "test error message")
})
