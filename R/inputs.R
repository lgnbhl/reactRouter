#' Link
#' @rdname Link
#' @description \url{https://api.reactrouter.com/v7/variables/react-router.Link.html}
#'
#' \strong{Repeat clicks.} The Shiny input value is the link's \code{to}
#' string. Clicking the same link twice publishes the same value, and Shiny
#' suppresses identical-value updates by default — your
#' \code{observeEvent(input$myLink, ...)} will fire only on the first click.
#' If you need to react to every click (e.g. logging, refreshing a panel),
#' bind to a counter or use \code{shiny::observeEvent(..., ignoreNULL = FALSE,
#' priority = "event")} alongside an explicit click counter, or wrap the
#' click target in a regular \code{shiny::actionButton()} that triggers the
#' navigation programmatically.
#'
#' @param ... Props to pass to element.
#' @param inputId ID of the component.
#' @param reloadDocument Boolean. Default FALSE. Let browser handle the transition normally
#' @param session For \code{updateLink.shinyInput()} / \code{updateNavLink.shinyInput()}
#'   only: the Shiny session object. Defaults to the current reactive domain.
#'   Not used by \code{Link.shinyInput()} / \code{NavLink.shinyInput()} themselves.
#' @export
Link.shinyInput <- function(inputId, ..., reloadDocument = FALSE) {
  checkmate::assert_string(inputId)
  checkmate::assert_flag(reloadDocument)

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
#'
#' \strong{Repeat clicks.} The Shiny input value is the link's \code{to}
#' string; clicking the same link twice publishes the same value and Shiny
#' suppresses identical-value updates by default. See
#' \code{\link{Link.shinyInput}} for the workaround.
#'
#' @param ... Props to pass to element.
#' @param inputId ID of the component.
#' @param reloadDocument Boolean. Default FALSE Let browser handle the transition normally
#' @param session For \code{updateLink.shinyInput()} / \code{updateNavLink.shinyInput()}
#'   only: the Shiny session object. Defaults to the current reactive domain.
#'   Not used by \code{Link.shinyInput()} / \code{NavLink.shinyInput()} themselves.
#' @export
NavLink.shinyInput <- function(inputId, ..., reloadDocument = FALSE) {
  checkmate::assert_string(inputId)
  checkmate::assert_flag(reloadDocument)

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
