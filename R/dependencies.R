#' react-router-dom JS dependency
#'
#' @return HTML dependency object.
#'
#' @export
reactRouterDependency <- function() {
  htmltools::htmlDependency(
    name = "reactRouter",
    version = "0.0.1",
    package = "reactRouter",
    src = c(file = "reactRouter"),
    script = "react-router-dom.js"
  )
}
