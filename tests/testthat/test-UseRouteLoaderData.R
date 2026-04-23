test_that("useRouteLoaderData() accesses parent route loader data", {
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = testthat::test_path("test-apps", "UseRouteLoaderData")
  )
  app$wait_for_idle()

  app_url <- app$get_url()

  app_child <- shinytest2::AppDriver$new(
    paste0(app_url, "/#/child")
  )
  app_child$wait_for_idle()

  root_all <- app_child$get_text("#rootDataAll")
  expect_true(grepl('"title"', root_all))
  expect_true(grepl('"Root Data"', root_all))

  root_title <- app_child$get_text("#rootDataTitle")
  expect_equal(root_title, "Root Data")
})
