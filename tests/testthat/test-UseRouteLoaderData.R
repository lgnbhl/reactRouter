test_that("useRouteLoaderData() accesses parent route loader data", {
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = testthat::test_path("test-apps", "UseRouteLoaderData")
  )
  app$wait_for_idle()

  app$get_js("window.location.hash = '#/child'")
  app$wait_for_idle()

  root_all <- app$get_text("#rootDataAll")
  expect_true(grepl('"title"', root_all))
  expect_true(grepl('"Root Data"', root_all))

  root_title <- app$get_text("#rootDataTitle")
  expect_equal(root_title, "Root Data")
})
