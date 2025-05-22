#' Run reactRouterExample example
#'
#' Launch a Shiny example app or list the available examples.
#' Use `reactRouter::reactRouterExample("basic")` to run a showcase app.
#'
#' @param example The name of the example to run, or `NULL` to retrieve the list of examples.
#' @param ... Additional arguments to pass to `shiny::runApp()`.
#' @return This function normally does not return;
#' interrupt R to stop the application (usually by pressing Ctrl+C or Esc).
#'
#' @seealso [shiny.blueprint::runExample()] which this function is an adaptation.
#'
#' @export
reactRouterExample <- function(example = NULL, ...) {
  examples <- system.file("examples", package = utils::packageName(), mustWork = TRUE)
  if (is.null(example)) {
    sub("\\.R$", "", list.files(examples))
  } else {
    path <- file.path(examples, example)
    if (!grepl("\\.R$", path) && !file.exists(path)) {
      path <- paste0(path, ".R")
    }
    shiny::runApp(path, ...)
  }
}
