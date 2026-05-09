#' Link
#' @rdname Link
#' @description \url{https://api.reactrouter.com/v7/variables/react-router.Link.html}
#' @param ... Props to pass to element.
#' @param inputId ID of the component.
#' @param reloadDocument Boolean. Default FALSE. Let browser handle the transition normally
#' @param session The Shiny session object. Defaults to the current reactive domain.
#' @export
Link.shinyInput <- function(inputId, ..., reloadDocument = FALSE) {
  checkmate::assert_string(inputId)
  checkmate::assert_logical(reloadDocument)

  shiny.react::reactElement(
    module = "@/reactRouter",
    name = "Link",
    props = shiny.react::asProps(
      inputId = inputId,
      ...,
      reloadDocument = reloadDocument
    ),
    deps = reactRouterDependency()
  )
}

#' @rdname Link
#' @export
updateLink.shinyInput <- shiny.react::updateReactInput

#' NavLink
#' @rdname NavLink
#' @description \url{https://api.reactrouter.com/v7/variables/react-router.NavLink.html}
#' @param ... Props to pass to element.
#' @param inputId ID of the component.
#' @param reloadDocument Boolean. Default FALSE Let browser handle the transition normally
#' @param session The Shiny session object. Defaults to the current reactive domain.
#' @export
NavLink.shinyInput <- function(inputId, ..., reloadDocument = FALSE) {
  checkmate::assert_string(inputId)
  checkmate::assert_logical(reloadDocument)

  shiny.react::reactElement(
    module = "@/reactRouter",
    name = "NavLink",
    props = shiny.react::asProps(
      inputId = inputId,
      ...,
      reloadDocument = reloadDocument
    ),
    deps = reactRouterDependency()
  )
}

#' @rdname NavLink
#' @export
updateNavLink.shinyInput <- shiny.react::updateReactInput
