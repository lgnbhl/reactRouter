input <- function(name) {
  function(inputId, ...) {
    checkmate::assert_string(inputId)
    shiny.react::reactElement(
      module = "@/shinyReactRouter",
      name = name,
      props = shiny.react::asProps(inputId = inputId, ...),
      deps = reactRouterDependency()
    )
  }
}

#' Link
#' @rdname Link
#' @description \url{https://reactrouter.com/en/main/components/link}
#' @param ... Props to pass to element.
#' @param inputId ID of the component.
#' @param session Object passed as the `session` argument to Shiny server.
#' @export
Link.shinyInput <- input('Link')

#' @rdname Link
#' @export
updateLink.shinyInput <- shiny.react::updateReactInput

#' NavLink
#' @rdname NavLink
#' @description \url{https://reactrouter.com/en/main/components/nav-link}
#' @param ... Props to pass to element.
#' @param inputId ID of the component.
#' @param session Object passed as the `session` argument to Shiny server.
#' @export
NavLink.shinyInput <- input('NavLink')

#' @rdname NavLink
#' @export
updateNavLink.shinyInput <- shiny.react::updateReactInput
