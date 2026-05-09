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
#' @seealso \code{shiny.blueprint::runExample()}, which this function is
#'   adapted from.
#'
#' @export
reactRouterExample <- function(example = NULL, ...) {
  examples <- system.file("examples", package = utils::packageName(), mustWork = TRUE)
  valid <- sub("\\.R$", "", list.files(examples))
  if (is.null(example)) {
    message(
      "Available reactRouter examples:\n",
      paste0("  - ", valid, collapse = "\n"),
      "\n\nRun one with reactRouterExample(\"<name>\")."
    )
    return(invisible(valid))
  }
  if (!is.character(example) || length(example) != 1 || is.na(example)) {
    stop("reactRouterExample(): `example` must be a single, non-NA character string.", call. = FALSE)
  }
  if (!example %in% valid) {
    stop(sprintf(
      "reactRouterExample(): unknown example '%s'. Available: %s.",
      example, paste(valid, collapse = ", ")
    ), call. = FALSE)
  }
  shiny::runApp(file.path(examples, example), ...)
}
