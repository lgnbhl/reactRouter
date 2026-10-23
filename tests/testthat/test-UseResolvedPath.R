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

test_that("useHref() and useResolvedPath() honour `relative`", {
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = testthat::test_path("test-apps", "UseHrefResolvedPath")
  )
  app$wait_for_idle()

  app$get_js("window.location.hash = '#/products/42'")
  app$wait_for_idle()

  # Default ("route"): ".." leaves the products/:id route -> /settings.
  # "path": ".." drops one URL segment (42) -> /products/settings.
  expect_equal(app$get_text("#hrefPathRelative"), "#/products/settings")
  expect_equal(app$get_text("#resolvedPathRelative"), "/products/settings")
})

test_that("useHref() and useResolvedPath() validate `relative`", {
  expect_no_error(useHref(shiny::span(), to = "/a", relative = "path"))
  expect_error(useHref(shiny::span(), to = "/a", relative = "url"), '`relative` must be NULL, "route" or "path"', fixed = TRUE)
  expect_error(useResolvedPath(shiny::span(), to = "/a", relative = TRUE), '`relative` must be NULL, "route" or "path"', fixed = TRUE)
})

test_that("useViewTransitionState() and useLinkClickHandler() validate `relative`", {
  expect_no_error(useViewTransitionState(shiny::span(), to = "/a", relative = "path"))
  expect_error(useViewTransitionState(shiny::span(), to = "/a", relative = "url"), '`relative` must be NULL, "route" or "path"', fixed = TRUE)
  expect_error(
    useLinkClickHandler(to = "/a", render = JS("h => null"), relative = c("route", "path")),
    '`relative` must be NULL, "route" or "path"',
    fixed = TRUE
  )
})
