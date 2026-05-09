#' Print reactRouter components
#'
#' When called interactively, renders the component in the IDE viewer panel.
#' Otherwise, falls back to standard shiny.tag printing (raw HTML text).
#'
#' @param x A reactRouter object (also inherits shiny.tag).
#' @param browse Whether to render in viewer. Defaults to TRUE in interactive sessions.
#' @param ... Additional arguments passed to print.
#' @return Invisibly returns x.
#'
#' @export
print.reactRouter <- function(x, browse = interactive(), ...) {
  rendered <- FALSE
  if (browse) {
    # Fall back to plain shiny.tag printing if the htmltools render path
    # fails -- e.g. a partial install where the bundled JS dependency is
    # missing. Better an HTML dump than an opaque htmltools error from
    # what is, after all, just a print() call.
    rendered <- tryCatch({
      htmltools::html_print(htmltools::browsable(x))
      TRUE
    }, error = function(e) FALSE)
  }
  if (!rendered) {
    NextMethod("print")
  }
  invisible(x)
}
