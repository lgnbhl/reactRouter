# Pure-R unit tests for the call-time validation introduced for the
# function-returning hooks and the missing()-arg guards.

test_that("function-returning hooks reject `into` with as = 'children'", {
  for (info in list(
    list(fn = useNavigate,         label = "useNavigate"),
    list(fn = useSubmit,           label = "useSubmit")
  )) {
    expect_error(
      info$fn(into = htmltools::tags$button("Go")),
      "cannot be injected as `children`",
      fixed = TRUE
    )
  }

  expect_error(
    useLinkClickHandler(to = "/x", into = htmltools::tags$span()),
    "cannot be injected as `children`",
    fixed = TRUE
  )
})

test_that("function-returning hooks accept render = JS(...)", {
  expect_no_error(useNavigate(render = JS("nav => nav")))
  expect_no_error(useSubmit(render = JS("submit => submit")))
  expect_no_error(useLinkClickHandler(to = "/x", render = JS("h => h")))
})

test_that("useNavigate/useSubmit reject as = 'onClick' (unsafe signature)", {
  expect_error(
    useNavigate(into = htmltools::tags$button("Go"), as = "onClick"),
    'unsafe',
    fixed = TRUE
  )
  expect_error(
    useSubmit(into = htmltools::tags$button("Save"), as = "onClick"),
    'unsafe',
    fixed = TRUE
  )
})

test_that("useLinkClickHandler accepts as = 'onClick' (MouseEvent signature)", {
  expect_no_error(
    useLinkClickHandler(
      to = "/x",
      into = htmltools::tags$span("link"),
      as = "onClick"
    )
  )
})

test_that("function-returning hooks accept other explicit non-children as", {
  expect_no_error(
    useNavigate(into = htmltools::tags$button("Go"), as = "onMouseEnter")
  )
  expect_no_error(
    useSubmit(into = htmltools::tags$button("Save"), as = "onMouseEnter")
  )
})

test_that("missing() guards on required positional args fire", {
  expect_error(useHref(), "`to` is required", fixed = TRUE)
  expect_error(useResolvedPath(), "`to` is required", fixed = TRUE)
  expect_error(useViewTransitionState(), "`to` is required", fixed = TRUE)
  expect_error(useLinkClickHandler(), "`to` is required", fixed = TRUE)
  expect_error(useMatch(), "`pattern` is required", fixed = TRUE)
  expect_error(useRouteLoaderData(), "`routeId` is required", fixed = TRUE)
})
