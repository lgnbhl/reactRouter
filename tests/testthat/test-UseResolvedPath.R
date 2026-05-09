test_that("useHref() and useResolvedPath() resolve paths", {
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = testthat::test_path("test-apps", "UseHrefResolvedPath")
  )
  app$wait_for_idle()

  app$get_js("window.location.hash = '#/products/42'")
  app$wait_for_idle()

  href_relative <- app$get_text("#hrefRelative")
  expect_equal(href_relative, "#/settings")

  href_absolute <- app$get_text("#hrefAbsolute")
  expect_equal(href_absolute, "#/home")

  resolved_all <- app$get_text("#resolvedAll")
  expect_true(grepl('"pathname"', resolved_all))

  resolved_pathname <- app$get_text("#resolvedPathname")
  expect_equal(resolved_pathname, "/settings")
})
