test_that("useBeforeUnload() runs the callback on beforeunload", {
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = testthat::test_path("test-apps", "UseBeforeUnload")
  )
  app$wait_for_idle()

  expect_null(app$get_js("window.beforeUnloadCalls"))

  app$run_js("window.dispatchEvent(new Event('beforeunload'))")
  expect_equal(app$get_js("window.beforeUnloadCalls"), 1)
})

test_that("useBeforeUnload() validates its arguments", {
  expect_error(useBeforeUnload(), "`callback` must be a JS() expression", fixed = TRUE)
  expect_error(useBeforeUnload(function(e) NULL), "`callback` must be a JS() expression", fixed = TRUE)
  expect_error(useBeforeUnload(JS("e => {}"), capture = "yes"), "`capture` must be NULL, TRUE or FALSE", fixed = TRUE)
  expect_no_error(useBeforeUnload(JS("e => {}"), capture = TRUE))
})
