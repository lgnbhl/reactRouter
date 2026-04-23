test_that("useNavigationType() renders navigation type", {
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = testthat::test_path("test-apps", "UseNavigationType")
  )
  app$wait_for_idle()

  nav_type_text <- app$get_text("#navType")
  expect_equal(nav_type_text, "POP")
})
