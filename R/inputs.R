input_link <- function(name) {
  function(inputId, ..., reloadDocument = TRUE) {
    checkmate::assert_string(inputId)
    shiny.react::reactElement(
      module = "@/reactRouter",
      name = name,
      props = shiny.react::asProps(inputId = inputId, ..., reloadDocument = reloadDocument),
      deps = reactRouterDependency()
    )
  }
}

#' Link
#' @rdname Link
#' @description \url{https://reactrouter.com/6.30.0/components/link}
#' @param ... Props to pass to element.
#' @param inputId ID of the component.
#' @param reloadDocument Boolean. Default TRUE. Let browser handle the transition normally 
#' @param session Object passed as the `session` argument to Shiny server.
#' @export
Link.shinyInput <- function(inputId, ..., reloadDocument = TRUE) {
  checkmate::assert_string(inputId)
  checkmate::assert_logical(reloadDocument)
  shiny.react::reactElement(
    module = "@/reactRouter",
    name = "Link",
    props = shiny.react::asProps(inputId = inputId, ..., reloadDocument = reloadDocument),
    deps = reactRouterDependency()
  )
}

#' @rdname Link
#' @export
updateLink.shinyInput <- shiny.react::updateReactInput

#' NavLink
#' @rdname NavLink
#' @description \url{https://reactrouter.com/6.30.0/components/nav-link}
#' @param ... Props to pass to element.
#' @param inputId ID of the component.
#' @param reloadDocument Boolean. Default TRUE. Let browser handle the transition normally 
#' @param session Object passed as the `session` argument to Shiny server.
#' @export
NavLink.shinyInput <- function(inputId, ..., reloadDocument = TRUE) {
  checkmate::assert_string(inputId)
  checkmate::assert_logical(reloadDocument)
  shiny.react::reactElement(
    module = "@/reactRouter",
    name = "NavLink",
    props = shiny.react::asProps(inputId = inputId, ..., reloadDocument = reloadDocument),
    deps = reactRouterDependency()
  )
}

#' @rdname NavLink
#' @export
updateNavLink.shinyInput <- shiny.react::updateReactInput
