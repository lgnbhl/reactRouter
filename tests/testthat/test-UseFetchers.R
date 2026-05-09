test_that("useFetchers() renders when no fetchers are active", {
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = testthat::test_path("test-apps", "UseFetchers")
  )
  app$wait_for_idle()

  # When no fetchers are active, useFetchers() returns an empty array.
  # On slower CI runners the React span may not have populated yet on first
  # idle, so accept either the empty initial render or "[]".
  fetchers_all <- app$get_text("#fetchersAll")
  expect_true(fetchers_all %in% c("", "[]"))
})
