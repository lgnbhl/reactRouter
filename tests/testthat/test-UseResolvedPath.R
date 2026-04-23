test_that("useHref() and useResolvedPath() resolve paths", {
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = testthat::test_path("test-apps", "UseHrefResolvedPath")
  )
  app$wait_for_idle()

  app_url <- app$get_url()

  app_product <- shinytest2::AppDriver$new(
    paste0(app_url, "/#/products/42")
  )
  app_product$wait_for_idle()

  href_relative <- app_product$get_text("#hrefRelative")
  expect_equal(href_relative, "#/settings")

  href_absolute <- app_product$get_text("#hrefAbsolute")
  expect_equal(href_absolute, "#/home")

  resolved_all <- app_product$get_text("#resolvedAll")
  expect_true(grepl('"pathname"', resolved_all))

  resolved_pathname <- app_product$get_text("#resolvedPathname")
  expect_equal(resolved_pathname, "/settings")
})
