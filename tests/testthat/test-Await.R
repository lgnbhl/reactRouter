test_that("Await resolves deferred loader data (selector and render paths)", {
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = testthat::test_path("test-apps", "Await")
  )
  app$wait_for_idle()

  app$get_js("window.location.hash = '#/report'")
  app$wait_for_idle()

  # Fast (non-deferred) loader value should already be visible.
  expect_equal(app$get_text("#title"), "Q1")

  # The deferred promise resolves after ~250 ms; wait_for_idle should cover
  # that, but give Suspense a moment to commit the resolved tree.
  app$wait_for_idle(duration = 500)

  expect_equal(app$get_text("#revenue"), "$1.2M")
  expect_equal(app$get_text("#usersRender"), "18430 users")
})

test_that("Await(): combining into/render with children is rejected", {
  # Name every formal arg so the trailing positional lands in `...` (children),
  # not in `as`/`selector`/etc.
  expect_error(
    reactRouter::Await(
      into = htmltools::tags$span(),
      as = "children",
      resolveKey = "x",
      selector = NULL,
      render = NULL,
      errorElement = NULL,
      fallback = NULL,
      htmltools::tags$div("child")
    ),
    "not both",
    fixed = TRUE
  )
})

test_that("Await(): missing resolveKey is reported clearly", {
  expect_error(
    reactRouter::Await(htmltools::tags$span()),
    "`resolveKey` is required",
    fixed = TRUE
  )
})
