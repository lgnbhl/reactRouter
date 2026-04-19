test_that("useBlocker() renders blocker state", {
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = testthat::test_path("test-apps", "UseBlocker")
  )
  app$wait_for_idle()

  # At rest with no navigation attempted, blocker state is "unblocked"
  blocker_state <- app$get_text("#blockerState")
  expect_equal(blocker_state, "unblocked")
})
