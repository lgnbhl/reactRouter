test_that("useMatch() renders match object or null", {
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = testthat::test_path("test-apps", "UseMatch")
  )
  app$wait_for_idle()

  app$get_js("window.location.hash = '#/products/7'")
  app$wait_for_idle()

  match_full <- app$get_text("#matchFull")
  expect_true(grepl('"params"', match_full))
  expect_true(grepl('"pathname"', match_full))

  match_params <- app$get_text("#matchParams")
  expect_true(grepl('"id"', match_params))
  expect_true(grepl('"7"', match_params))

  match_pathname <- app$get_text("#matchPathname")
  expect_equal(match_pathname, "/products/7")

  no_match <- app$get_text("#noMatch")
  expect_equal(no_match, "")
})
