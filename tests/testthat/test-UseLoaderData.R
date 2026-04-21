test_that("useLoaderData() renders loader data", {
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = testthat::test_path("test-apps", "useLoaderData")
  )
  app$wait_for_idle()

  app_url <- app$get_url()

  app_data <- shinytest2::AppDriver$new(
    paste0(app_url, "/#/data")
  )
  app_data$wait_for_idle()

  loader_all <- app_data$get_text("#loaderAll")
  expect_true(grepl('"name"', loader_all))
  expect_true(grepl('"Alice"', loader_all))

  loader_name <- app_data$get_text("#loaderName")
  expect_equal(loader_name, "Alice")

  loader_age <- app_data$get_text("#loaderAge")
  expect_equal(loader_age, "30")

  # render = JS(...) path: receives full loader object, composes a string
  loader_name_render <- app_data$get_text("#loaderNameRender")
  expect_equal(loader_name_render, "Alice, age 30")
})
