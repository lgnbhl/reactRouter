test_that("MemoryRouter renders with initialEntries", {
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = testthat::test_path("test-apps", "MemoryRouter")
  )
  app$wait_for_idle()

  about_text <- app$get_text("#memAbout")
  expect_true(grepl("memory about", about_text))
})
