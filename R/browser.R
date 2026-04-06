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
  if (browse) {
    htmltools::html_print(htmltools::browsable(x))
  } else {
    NextMethod("print")
  }
  invisible(x)
}
