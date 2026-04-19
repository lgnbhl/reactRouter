test_that("useFetchers() renders when no fetchers are active", {
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = testthat::test_path("test-apps", "UseFetchers")
  )
  app$wait_for_idle()

  # When no fetchers are active, useFetchers() returns an empty array
  fetchers_all <- app$get_text("#fetchersAll")
  expect_equal(fetchers_all, "[]")
})
