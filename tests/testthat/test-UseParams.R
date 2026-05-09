test_that("useParams() renders route parameters", {
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = testthat::test_path("test-apps", "UseParams")
  )
  app$wait_for_idle()

  app$get_js("window.location.hash = '#/user/42'")
  app$wait_for_idle()

  param_text <- app$get_text("#paramId")
  expect_equal(param_text, "42")

  param_json <- app$get_text("#paramAll")
  expect_true(grepl('"id"', param_json))
  expect_true(grepl('"42"', param_json))
})
