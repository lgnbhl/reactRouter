#' Documentation template for components
#'
#' @param ... Props to pass to the component.
#' The allowed props are listed below in the \bold{Details} section.
#'
#' @return
#' Object with `shiny.tag` class suitable for use in the UI of a Shiny app.
#'
#' @keywords internal
#' @name component
NULL

component <- function(name, module = 'react-router-dom') {
  function(...) {
    shiny.react::reactElement(
      module = module,
      name = name,
      props = shiny.react::asProps(...),
      deps = reactRouterDependency()
    )
  }
}

#' HashRouter
#' @rdname HashRouter
#' @description \url{https://api.reactrouter.com/v7/functions/react-router.HashRouter.html}
#' @param ... Props to pass to element.
#' @return A HashRouter component.
#' @export
HashRouter <- function(...) {
  tag <- shiny.react::reactElement(
    module = 'react-router-dom',
    name = "HashRouter",
    props = shiny.react::asProps(...),
    deps = reactRouterDependency()
  )
  class(tag) <- c("reactRouter", class(tag))
  tag
}

#' BrowserRouter
#' @rdname BrowserRouter
#' @description \url{https://api.reactrouter.com/v7/functions/react-router.BrowserRouter.html}
#' @param ... Props to pass to element.
#' @return A BrowserRouter component.
#' @export
BrowserRouter <- function(...) {
  tag <- shiny.react::reactElement(
    module = 'react-router-dom',
    name = "BrowserRouter",
    props = shiny.react::asProps(...),
    deps = reactRouterDependency()
  )
  class(tag) <- c("reactRouter", class(tag))
  tag
}

#' MemoryRouter
#' @rdname MemoryRouter
#' @description \url{https://api.reactrouter.com/v7/functions/react-router.MemoryRouter.html}
#' @param ... Props to pass to element.
#' @return A MemoryRouter component.
#' @export
MemoryRouter <- function(...) {
  tag <- shiny.react::reactElement(
    module = 'react-router-dom',
    name = "MemoryRouter",
    props = shiny.react::asProps(...),
    deps = reactRouterDependency()
  )
  class(tag) <- c("reactRouter", class(tag))
  tag
}

#' Route
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.Route.html}
#'
#' Internally the `element` is wrapped in a `shiny::div()`
#' with a UUID key so, in case R shiny is used, shiny can differentiate
#' each element.
#'
#' @rdname Route
#' @param ... Props to pass to element.
#' @param element element wrapped in a `shiny::div()`.
#' @param key By default uses a UUID key in the `div()` of the `element` arg.
#' @return A Route component.
#' @param loader Optional. Can be:
#'   - A data.frame or list: serialized as a static JS loader
#'   - An R function: called at build time (no params available)
#'   - A JS() expression: passed through as-is
#' @export
Route <- function(..., element, loader = NULL, key = uuid::UUIDgenerate()) {
  shiny.react::reactElement(
    module = "react-router-dom",
    name = "Route",
    props = shiny.react::asProps(
      ...,
      loader = loader,
      element = shiny::div(
        key = key,
        element
      )
    ),
    deps = reactRouterDependency()
  )
}

#' Link
#'
#' \url{https://api.reactrouter.com/v7/variables/react-router.Link.html}
#'
#' The `reloadDocument` prop controls whether clicking the link triggers a full
#' page reload (`TRUE`) or client-side navigation (`FALSE`). The default is
#' `FALSE`, matching React Router's own default. Set `reloadDocument = TRUE` in
#' Shiny apps that use server-rendered UI (`uiOutput`/`renderUI`) so that
#' Shiny can re-initialize and read the new URL hash.
#'
#' @rdname Link
#' @param ... Props to pass to element.
#' @param reloadDocument Boolean. Default `FALSE`. Set to `TRUE` for Shiny apps
#'   with server-rendered content.
#' @return A Link component.
#' @export
Link <- function(..., reloadDocument = FALSE) {
  # Check if the user did NOT provide the argument
  if (missing(reloadDocument)) {
    lifecycle::deprecate_warn(
      when = "0.2.0",
      what = "Link(reloadDocument = 'default is now FALSE')",
      details = "The default of `reloadDocument` was TRUE in version 0.1.1. It is now FALSE."
    )
  }

  shiny.react::reactElement(
    module = "react-router-dom",
    name = "Link",
    props = shiny.react::asProps(
      ...,
      reloadDocument = reloadDocument
    ),
    deps = reactRouterDependency()
  )
}

#' Navigate
#' @rdname Navigate
#' @description \url{https://api.reactrouter.com/v7/functions/react-router.Navigate.html}
#' @param ... Props to pass to element.
#' @return A Navigate component.
#' @export
Navigate <- component('Navigate')

#' NavLink
#'
#' \url{https://api.reactrouter.com/v7/variables/react-router.NavLink.html}
#'
#' The `reloadDocument` prop controls whether clicking the link triggers a full
#' page reload (`TRUE`) or client-side navigation (`FALSE`). The default is
#' `FALSE`, matching React Router's own default. Set `reloadDocument = TRUE` in
#' Shiny apps that use server-rendered UI (`uiOutput`/`renderUI`) so that
#' Shiny can re-initialize and read the new URL hash.
#'
#' @rdname NavLink
#' @param ... Props to pass to element.
#' @param reloadDocument Boolean. Default `FALSE`. Set to `TRUE` for Shiny apps
#'   with server-rendered content.
#' @return A NavLink component.
#' @export
NavLink <- function(..., reloadDocument = FALSE) {
  # Check if the user did NOT provide the argument
  if (missing(reloadDocument)) {
    lifecycle::deprecate_warn(
      when = "0.2.0",
      what = "NavLink(reloadDocument = 'default is now FALSE')",
      details = "The default of `reloadDocument` was TRUE in version 0.1.1. It is now FALSE."
    )
  }

  shiny.react::reactElement(
    module = "react-router-dom",
    name = "NavLink",
    props = shiny.react::asProps(
      ...,
      reloadDocument = reloadDocument
    ),
    deps = reactRouterDependency()
  )
}


#' Outlet
#' @rdname Outlet
#' @description \url{https://api.reactrouter.com/v7/functions/react-router.Outlet.html}
#' @param ... Props to pass to element.
#' @return A Outlet component.
#' @export
Outlet <- component('Outlet')

#' Routes
#' @rdname Routes
#' @description \url{https://api.reactrouter.com/v7/functions/react-router.Routes.html}
#' @param ... Props to pass to element.
#' @return A Routes component.
#' @export
Routes <- component('Routes')

#' Form
#' @rdname Form
#' @description \url{https://api.reactrouter.com/v7/variables/react-router.Form.html}
#' @param ... Props to pass to element.
#' @return A Form component.
#' @export
Form <- component('Form')

#' ScrollRestoration
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.ScrollRestoration.html}
#'
#' Emulates the browser's scroll restoration on location changes after loaders
#' have completed. Place once inside the root layout of a data router app.
#' Requires a data router (\code{\link{createBrowserRouter}},
#' \code{\link{createHashRouter}}, etc.).
#'
#' @rdname ScrollRestoration
#' @param ... Props to pass to element. Notable props: \code{getKey} (a
#'   \code{\link{JS}} function to compute the scroll key from the location)
#'   and \code{storageKey} (Character, custom \code{sessionStorage} key).
#' @return A ScrollRestoration component.
#' @export
ScrollRestoration <- component('ScrollRestoration')
