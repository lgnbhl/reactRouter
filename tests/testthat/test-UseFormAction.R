test_that("useFormAction() resolves form action URLs", {
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = testthat::test_path("test-apps", "UseFormAction")
  )
  app$wait_for_idle()

  app$get_js("window.location.hash = '#/products/42?q=1'")
  app$wait_for_idle()

  # No action: the current route, keeping the current search params.
  expect_equal(app$get_text("#actionDefault"), "/products/42?q=1")
  # An explicit action resolves relative to the route and drops the search.
  expect_equal(app$get_text("#actionChild"), "/products/42/edit")
  # Default ("route"): ".." leaves the products/:id route -> /.
  # "path": ".." drops one URL segment (42) -> /products.
  expect_equal(app$get_text("#actionParentRoute"), "/")
  expect_equal(app$get_text("#actionParentPath"), "/products")
  # Injected as a prop rather than as children.
  expect_equal(
    app$get_js("document.querySelector('#formInto span').getAttribute('data-action')"),
    "/products/42/edit"
  )
})

test_that("useFormAction() validates its arguments", {
  expect_no_error(useFormAction(shiny::span()))
  expect_no_error(useFormAction(shiny::span(), action = "edit", relative = "path"))
  expect_error(useFormAction(), "provide either `into`", fixed = TRUE)
  expect_error(useFormAction(shiny::span(), action = 1), "`action` must be NULL or a single string", fixed = TRUE)
  expect_error(useFormAction(shiny::span(), relative = "url"), '`relative` must be NULL, "route" or "path"', fixed = TRUE)
})
