test_that("useSearchParams() renders query parameters", {
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = testthat::test_path("test-apps", "UseSearchParams")
  )
  app$wait_for_idle()

  app_url <- app$get_url()

  app_with_params <- shinytest2::AppDriver$new(
    paste0(app_url, "/#/?color=red")
  )
  app_with_params$wait_for_idle()

  color_text <- app_with_params$get_text("#colorParam")
  expect_equal(color_text, "red")

  all_text <- app_with_params$get_text("#allParams")
  expect_true(grepl('"color"', all_text))
  expect_true(grepl('"red"', all_text))
})
