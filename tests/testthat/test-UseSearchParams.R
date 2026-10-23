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

test_that("useSearchParams(single = TRUE) returns only the first value", {
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = testthat::test_path("test-apps", "UseSearchParams")
  )
  app$wait_for_idle()

  app$get_js("window.location.hash = '#/?tag=a&tag=b&color=red'")
  app$wait_for_idle()

  expect_equal(app$get_text("#tagAll"), "a, b")
  expect_equal(app$get_text("#tagSingle"), "a")

  all_single <- app$get_text("#allSingle")
  expect_true(grepl('"tag": "a"', all_single, fixed = TRUE))
  expect_false(grepl('"b"', all_single, fixed = TRUE))
})

test_that("useSearchParams() validates `single`", {
  expect_error(
    reactRouter::useSearchParams(htmltools::tags$span(), single = "yes"),
    "`single` must be TRUE or FALSE"
  )
  expect_error(
    reactRouter::useSearchParams(htmltools::tags$span(), single = NA),
    "`single` must be TRUE or FALSE"
  )
})
