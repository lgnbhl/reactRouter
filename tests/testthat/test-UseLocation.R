test_that("useLocation() renders location properties", {
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = testthat::test_path("test-apps", "UseLocation")
  )
  app$wait_for_idle()

  app$get_js("window.location.hash = '#/about?q=test'")
  app$wait_for_idle()

  pathname_text <- app$get_text("#locPathname")
  expect_equal(pathname_text, "/about")

  search_text <- app$get_text("#locSearch")
  expect_equal(search_text, "?q=test")

  hash_text <- app$get_text("#locHash")
  expect_equal(hash_text, "")

  all_text <- app$get_text("#locAll")
  expect_true(grepl('"pathname"', all_text))
  expect_true(grepl('"/about"', all_text))
})
