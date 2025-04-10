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
    src = c(file = "reactRouter-6.30.0"),
    script = "react-router-dom.js"
  )
}
