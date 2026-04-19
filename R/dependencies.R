#' react-router-dom JS dependency
#'
#' @return HTML dependency object.
#'
#' @export
reactRouterDependency <- function() {
  htmltools::htmlDependency(
    name = "reactRouter",
    version = as.character(utils::packageVersion("reactRouter")),
    package = "reactRouter",
    src = c(file = "reactRouter"),
    script = "react-router-dom.js"
  )
}
