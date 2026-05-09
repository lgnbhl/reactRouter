test_that("useSearchParams() renders query parameters", {
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = testthat::test_path("test-apps", "UseSearchParams")
  )
  app$wait_for_idle()

  app$get_js("window.location.hash = '#/?color=red'")
  app$wait_for_idle()

  color_text <- app$get_text("#colorParam")
  expect_equal(color_text, "red")

  all_text <- app$get_text("#allParams")
  expect_true(grepl('"color"', all_text))
  expect_true(grepl('"red"', all_text))
})
