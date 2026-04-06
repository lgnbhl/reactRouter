test_that("Navigate redirects to the target route", {
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = testthat::test_path("test-apps", "Navigate")
  )
  app$wait_for_idle()

  app_url <- app$get_url()

  app_redirect <- shinytest2::AppDriver$new(
    paste0(app_url, "/#/old")
  )
  app_redirect$wait_for_idle()

  new_text <- app_redirect$get_text("#newPage")
  expect_true(grepl("new page", new_text))
})
