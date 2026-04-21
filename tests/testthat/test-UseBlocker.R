test_that("useBlocker() renders blocker state", {
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = testthat::test_path("test-apps", "UseBlocker")
  )
  app$wait_for_idle()

  # into/as/selector path: default selector = "state"
  blocker_state <- app$get_text("#blockerState")
  expect_equal(blocker_state, "unblocked")

  # render = JS(...) path: receives full blocker object, returns b.state
  blocker_state_render <- app$get_text("#blockerStateRender")
  expect_equal(blocker_state_render, "unblocked")
})
