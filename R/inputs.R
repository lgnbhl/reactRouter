input_link <- function(name) {
  function(inputId, ..., reloadDocument = TRUE) {
    checkmate::assert_string(inputId)
    shiny.react::reactElement(
      module = "@/reactRouter",
      name = name,
      props = shiny.react::asProps(
        inputId = inputId,
        ...,
        reloadDocument = reloadDocument
      ),
      deps = reactRouterDependency()
    )
  }
}

#' Link
#' @rdname Link
#' @description \url{https://api.reactrouter.com/v7/variables/react-router.Link.html}
#' @param ... Props to pass to element.
#' @param inputId ID of the component.
#' @param reloadDocument Boolean. Default TRUE. Let browser handle the transition normally
#' @param session Object passed as the `session` argument to Shiny server.
#' @export
Link.shinyInput <- function(inputId, ..., reloadDocument = TRUE) {
  checkmate::assert_string(inputId)
  checkmate::assert_logical(reloadDocument)

  if (missing(reloadDocument)) {
    lifecycle::deprecate_warn(
      when = "0.2.0",
      what = "Link.shinyInput(reloadDocument = 'default is now FALSE')",
      details = "The default of `reloadDocument` was TRUE in version 0.1.1. It is now FALSE."
    )
  }

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
#' @param reloadDocument Boolean. Default TRUE. Let browser handle the transition normally
#' @param session Object passed as the `session` argument to Shiny server.
#' @export
NavLink.shinyInput <- function(inputId, ..., reloadDocument = FALSE) {
  checkmate::assert_string(inputId)
  checkmate::assert_logical(reloadDocument)

  if (missing(reloadDocument)) {
    lifecycle::deprecate_warn(
      when = "0.2.0",
      what = "NavLink.shinyInput(reloadDocument = 'default is now FALSE')",
      details = "The default of `reloadDocument` was TRUE in version 0.1.1. It is now FALSE."
    )
  }

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
