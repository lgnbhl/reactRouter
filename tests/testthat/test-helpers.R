# Pure-R unit tests for the loader/action helpers — no browser needed.

test_that("redirect helpers reject unsafe URL schemes", {
  for (fn in list(redirect, replaceResponse, redirectDocument)) {
    for (bad in c(
      "javascript:alert(1)",
      "JavaScript:alert(1)",       # case-insensitive
      "  javascript:alert(1)",     # leading whitespace tolerated by browsers
      "data:text/html,<script>1</script>",
      "vbscript:msgbox(1)"
    )) {
      expect_error(fn(bad), "refusing unsafe URL scheme", fixed = TRUE)
    }
  }
})

test_that("redirect helpers reject protocol-relative URLs", {
  for (fn in list(redirect, replaceResponse, redirectDocument)) {
    expect_error(fn("//evil.example.com/x"), "protocol-relative", fixed = TRUE)
    expect_error(fn(" //evil.example.com/x"), "protocol-relative", fixed = TRUE)
  }
})

test_that("redirect helpers reject non-character / NA / multi-element `to`", {
  for (fn in list(redirect, replaceResponse, redirectDocument)) {
    expect_error(fn(NA_character_), "must be a single, non-NA")
    expect_error(fn(c("/a", "/b")), "must be a single, non-NA")
    expect_error(fn(42), "must be a single, non-NA")
  }
})

test_that("redirect helpers accept safe targets and emit JS via the helpers namespace", {
  for (info in list(
    list(fn = redirect,         js = "redirect"),
    list(fn = replaceResponse,  js = "replace"),
    list(fn = redirectDocument, js = "redirectDocument")
  )) {
    out <- info$fn("/safe")
    expect_s3_class(out, "JS_EVAL")
    txt <- as.character(out)
    expect_match(txt, "window.jsmodule['@/reactRouter'].helpers", fixed = TRUE)
    expect_match(txt, paste0(".", info$js, "("), fixed = TRUE)
    expect_match(txt, '"/safe"', fixed = TRUE)
  }
})

test_that("dataResponse(value = NULL) round-trips as `null`", {
  out <- dataResponse(NULL)
  txt <- as.character(out)
  expect_s3_class(out, "JS_EVAL")
  # No init -> just `data(null)`, no second arg.
  expect_match(txt, ".data(null)", fixed = TRUE)
})

test_that("dataResponse() requires an explicit `value`", {
  expect_error(dataResponse(), "`value` is required", fixed = TRUE)
})

test_that("dataResponse() serialises R lists and forwards init", {
  out <- dataResponse(list(name = "Ada"), init = list(status = 201))
  txt <- as.character(out)
  expect_match(txt, '{"name":"Ada"}', fixed = TRUE)
  expect_match(txt, '{"status":201}', fixed = TRUE)
})

test_that("dataResponse() preserves a JS() value as raw JS", {
  out <- dataResponse(shiny.react::JS("makeRows()"))
  txt <- as.character(out)
  # The JS() is inlined verbatim, not JSON-stringified.
  expect_match(txt, "makeRows()", fixed = TRUE)
  expect_false(grepl('"makeRows', txt, fixed = TRUE))
})

test_that("isRouteErrorResponse() returns a JS() reference into the helpers namespace", {
  out <- isRouteErrorResponse()
  expect_s3_class(out, "JS_EVAL")
  expect_identical(
    as.character(out),
    "window.jsmodule['@/reactRouter'].helpers.isRouteErrorResponse"
  )
})
