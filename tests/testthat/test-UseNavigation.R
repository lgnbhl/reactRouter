test_that("useNavigation() renders navigation state", {
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = testthat::test_path("test-apps", "useNavigation")
  )
  app$wait_for_idle()

  nav_state <- app$get_text("#navState")
  expect_equal(nav_state, "idle")

  nav_all <- app$get_text("#navAll")
  expect_true(grepl('"state"', nav_all))
  expect_true(grepl('"idle"', nav_all))
})
