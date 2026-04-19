test_that("useRevalidator() renders revalidation state", {
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = testthat::test_path("test-apps", "UseRevalidator")
  )
  app$wait_for_idle()

  revalidator_state <- app$get_text("#revalidatorState")
  expect_equal(revalidator_state, "idle")
})
