test_that("Link renders and routes work", {
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = testthat::test_path("test-apps", "Link")
  )
  app$wait_for_idle()

  link_text <- app$get_text("#linkAbout")
  expect_equal(link_text, "Go to About")

  home_text <- app$get_text("#homePage")
  expect_true(grepl("home", home_text))

  app$get_js("window.location.hash = '#/about'")
  app$wait_for_idle()

  about_text <- app$get_text("#aboutPage")
  expect_true(grepl("about content", about_text))
})
