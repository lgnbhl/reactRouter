test_that("useOutletContext() reads context passed through Outlet", {
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = testthat::test_path("test-apps", "UseOutletContext")
  )
  app$wait_for_idle()

  context_user <- app$get_text("#contextUser")
  expect_equal(context_user, "Alice")

  context_role <- app$get_text("#contextRole")
  expect_equal(context_role, "admin")

  context_all <- app$get_text("#contextAll")
  expect_true(grepl('"user"', context_all))
  expect_true(grepl('"Alice"', context_all))

  # render = JS(...) path: receives full context object, composes a string
  context_render <- app$get_text("#contextRender")
  expect_equal(context_render, "Alice (admin)")
})
