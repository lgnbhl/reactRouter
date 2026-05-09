#' Run reactRouterExample example
#'
#' Launch a Shiny example app or list the available examples.
#' Use `reactRouter::reactRouterExample("basic")` to run a showcase app.
#'
#' @param example The name of the example to run, or `NULL` to print and
#'   invisibly return the list of available examples.
#' @param ... Additional arguments to pass to `shiny::runApp()`.
#' @return When `example` is `NULL`, invisibly returns a character vector of
#'   example names (also printed via `message()`). Otherwise this function
#'   normally does not return; interrupt R to stop the application
#'   (usually by pressing Ctrl+C or Esc).
#'
#' @seealso [shiny.blueprint::runExample()] which this function is an adaptation.
#'
#' @export
reactRouterExample <- function(example = NULL, ...) {
  examples <- system.file("examples", package = utils::packageName(), mustWork = TRUE)
  if (is.null(example)) {
    names <- sub("\\.R$", "", list.files(examples))
    message(
      "Available reactRouter examples:\n",
      paste0("  - ", names, collapse = "\n"),
      "\n\nRun one with reactRouterExample(\"<name>\")."
    )
    invisible(names)
  } else {
    path <- file.path(examples, example)
    if (!grepl("\\.R$", path) && !file.exists(path)) {
      path <- paste0(path, ".R")
    }
    shiny::runApp(path, ...)
  }
}
