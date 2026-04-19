test_that("useFetcher() renders fetcher state", {
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = testthat::test_path("test-apps", "UseFetcher")
  )
  app$wait_for_idle()

  fetcher_state <- app$get_text("#fetcherState")
  expect_equal(fetcher_state, "idle")
})
