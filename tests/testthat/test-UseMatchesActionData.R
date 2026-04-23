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
    app_dir = testthat::test_path("test-apps", "useMatchesActionData")
  )
  app$wait_for_idle()

  app_url <- app$get_url()

  app_form <- shinytest2::AppDriver$new(
    paste0(app_url, "/#/form")
  )
  app_form$wait_for_idle()

  action_text <- app_form$get_text("#actionData")
  expect_equal(action_text, "")
})

test_that("Form submission populates useActionData()", {
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = testthat::test_path("test-apps", "useMatchesActionData")
  )
  app$wait_for_idle()

  app_url <- app$get_url()

  app_form <- shinytest2::AppDriver$new(
    paste0(app_url, "/#/form")
  )
  app_form$wait_for_idle()

  app_form$click(selector = "#submitBtn")
  app_form$wait_for_idle()

  action_text <- app_form$get_text("#actionData")
  expect_true(grepl('"submitted"', action_text))
  expect_true(grepl('"Bob"', action_text))

  action_field <- app_form$get_text("#actionField")
  expect_equal(action_field, "Bob")
})
