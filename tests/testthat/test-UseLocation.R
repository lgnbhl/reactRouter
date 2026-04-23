test_that("useLocation() renders location properties", {
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = testthat::test_path("test-apps", "UseLocation")
  )
  app$wait_for_idle()

  app_url <- app$get_url()

  app_with_path <- shinytest2::AppDriver$new(
    paste0(app_url, "/#/about?q=test")
  )
  app_with_path$wait_for_idle()

  pathname_text <- app_with_path$get_text("#locPathname")
  expect_equal(pathname_text, "/about")

  search_text <- app_with_path$get_text("#locSearch")
  expect_equal(search_text, "?q=test")

  hash_text <- app_with_path$get_text("#locHash")
  expect_equal(hash_text, "")

  all_text <- app_with_path$get_text("#locAll")
  expect_true(grepl('"pathname"', all_text))
  expect_true(grepl('"/about"', all_text))
})
