text_is <- function(app, id, value, timeout = 1000) {
  app$wait_for_js(
    sprintf("document.querySelector('#%s span')?.textContent === %s",
            id, jsonlite::toJSON(value, auto_unbox = TRUE)),
    timeout = timeout
  )
}

open_list <- function() {
  app <- shinytest2::AppDriver$new(
    app_dir = testthat::test_path("test-apps", "RenderInto")
  )
  app$wait_for_idle()
  app$run_js("window.location.hash = '#/list?ids=a'")
  text_is(app, "plain", "srv:a", timeout = 5000)
  app
}

test_that("render receives `into` with `...` props applied", {
  skip_on_cran()
  app <- open_list()

  expect_equal(app$get_js("document.querySelector('#extraProps span').title"), "extra")
  expect_no_error(text_is(app, "searchInto", "function:a"))
})

test_that("render can call useNavigation() for optimistic UI", {
  skip_on_cran()
  app <- open_list()

  app$run_js("window.location.hash = '#/list?ids=a,b'")
  # Pending: `render` reads the URL being loaded; the plain binding still
  # shows the previous loader result.
  expect_no_error(text_is(app, "optimistic", "a, b"))
  expect_equal(app$get_text("#plain span"), "srv:a")

  # Settled: the loader's answer takes over.
  expect_no_error(text_is(app, "optimistic", "srv:a, srv:b", timeout = 5000))
})

test_that("render may call hooks in wrappers that return null early", {
  skip_on_cran()
  app <- open_list()

  expect_no_error(app$wait_for_js(
    "document.querySelector('#matchHooks').textContent === 'match:idle'"
  ))
  # Leaving "/list" makes useMatch() null, so `render` (and its
  # useNavigation() call) is skipped; then match again.
  app$run_js("window.location.hash = '#/'")
  expect_no_error(app$wait_for_js(
    "document.querySelector('#matchHooks')?.textContent === ''"
  ))
  app$run_js("window.location.hash = '#/list?ids=a'")
  expect_no_error(app$wait_for_js(
    "document.querySelector('#matchHooks')?.textContent.startsWith('match:')",
    timeout = 5000
  ))
})
