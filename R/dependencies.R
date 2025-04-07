#' react-router-dom JS dependency
#'
#' @return HTML dependency object.
#'
#' @export
reactRouterDependency <- function() {
  htmltools::htmlDependency(
    name = "shinyReactRouter",
    version = "0.0.1",
    package = "shinyReactRouter",
    src = c(file = "shinyReactRouter-6.30.0"),
    script = "react-router-dom.js"
  )
}
