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

test_that("useSearchParams(defaultInit) applies defaults only for missing keys", {
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = testthat::test_path("test-apps", "UseSearchParams")
  )
  app$wait_for_idle()

  expect_equal(app$get_text("#tabDefault"), "overview")
  expect_equal(app$get_text("#tabDefaultString"), "summary")

  app$get_js("window.location.hash = '#/?tab=details'")
  app$wait_for_idle()

  expect_equal(app$get_text("#tabDefault"), "details")
  expect_equal(app$get_text("#tabDefaultString"), "details")
  # Defaults are read-only: they never appear in the URL.
  expect_false(grepl("overview", app$get_js("window.location.hash")))
})

test_that("useSearchParams() validates `defaultInit`", {
  expect_no_error(
    reactRouter::useSearchParams(htmltools::tags$span(), defaultInit = c(tab = "a"))
  )
  for (bad in list(c("a", "b"), list("a"), list(), 1, c(tab = "a", "b"))) {
    expect_error(
      reactRouter::useSearchParams(htmltools::tags$span(), defaultInit = bad),
      "`defaultInit` must be a named list"
    )
  }
})
