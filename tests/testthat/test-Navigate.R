test_that("Navigate redirects to the target route", {
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = testthat::test_path("test-apps", "Navigate")
  )
  app$wait_for_idle()

  app$get_js("window.location.hash = '#/old'")
  app$wait_for_idle()

  new_text <- app$get_text("#newPage")
  expect_true(grepl("new page", new_text))
})
