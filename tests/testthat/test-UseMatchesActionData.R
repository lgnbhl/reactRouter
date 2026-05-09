test_that("useMatches() renders route matches array", {
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = testthat::test_path("test-apps", "UseMatchesActionData")
  )
  app$wait_for_idle()

  matches_text <- app$get_text("#matchesAll")
  expect_true(grepl("root", matches_text))
  expect_true(grepl('"pathname"', matches_text))
})

test_that("useActionData() is null before form submission", {
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = testthat::test_path("test-apps", "UseMatchesActionData")
  )
  app$wait_for_idle()

  app$get_js("window.location.hash = '#/form'")
  app$wait_for_idle()

  action_text <- app$get_text("#actionData")
  expect_equal(action_text, "")
})

test_that("Form submission populates useActionData()", {
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = testthat::test_path("test-apps", "UseMatchesActionData")
  )
  app$wait_for_idle()

  app$get_js("window.location.hash = '#/form'")
  app$wait_for_idle()

  app$click(selector = "#submitBtn")
  app$wait_for_idle()

  action_text <- app$get_text("#actionData")
  expect_true(grepl('"submitted"', action_text))
  expect_true(grepl('"Bob"', action_text))

  action_field <- app$get_text("#actionField")
  expect_equal(action_field, "Bob")
})
