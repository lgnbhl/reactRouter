#' createBrowserRouter
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.createBrowserRouter.html}
#'
#' Creates a browser router using the data router API.
#' Use with \code{\link{createRoutesFromElements}} and \code{\link{Route}}.
#'
#' @rdname createBrowserRouter
#' @param ... \code{\link{Route}} elements. Pass directly, or (optionally)
#'   wrapped in \code{\link{createRoutesFromElements}} to mirror the
#'   official React Router v7 API.
#' @return A createBrowserRouter component.
#' @export
createBrowserRouter <- function(...) {
  tag <- shiny.react::reactElement(
    module = "@/reactRouter",
    name = "CreateBrowserRouter",
    props = shiny.react::asProps(...),
    deps = reactRouterDependency()
  )
  class(tag) <- c("reactRouter", class(tag))
  tag
}

#' createHashRouter
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.createHashRouter.html}
#'
#' Creates a hash router using the data router API.
#' Use with \code{\link{createRoutesFromElements}} and \code{\link{Route}}.
#'
#' @rdname createHashRouter
#' @param ... \code{\link{Route}} elements. Pass directly, or (optionally)
#'   wrapped in \code{\link{createRoutesFromElements}} to mirror the
#'   official React Router v7 API.
#' @return A createHashRouter component.
#' @export
createHashRouter <- function(...) {
  tag <- shiny.react::reactElement(
    module = "@/reactRouter",
    name = "CreateHashRouter",
    props = shiny.react::asProps(...),
    deps = reactRouterDependency()
  )
  class(tag) <- c("reactRouter", class(tag))
  tag
}

#' createRoutesFromElements
#'
#' \url{https://api.reactrouter.com/v7/variables/react-router.createRoutesFromElements.html}
#'
#' Optional compatibility alias. In R, \code{\link{createHashRouter}},
#' \code{\link{createBrowserRouter}}, and \code{\link{createMemoryRouter}}
#' accept \code{\link{Route}} elements directly, so wrapping them in
#' \code{createRoutesFromElements()} is not required. The function is kept
#' so that examples copied verbatim from the React Router v7 documentation
#' (\code{createHashRouter(createRoutesFromElements(...))}) keep working.
#'
#' The actual JSX-to-route-object conversion always happens on the
#' JavaScript side; this R function simply bundles its arguments into a
#' tag list.
#'
#' @rdname createRoutesFromElements
#' @param ... \code{\link{Route}} elements.
#' @return A tag list of Route elements.
#' @export
createRoutesFromElements <- function(...) {
  tag <- shiny::tagList(...)
  class(tag) <- c("reactRouter", class(tag))
  tag
}

#' createMemoryRouter
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.createMemoryRouter.html}
#'
#' Creates a memory router using the data router API. Routing state is kept
#' in memory and the browser URL is never read or modified, making it suitable
#' for static HTML pages (\code{file://}), Quarto documents, and embedded
#' widgets where the real URL is irrelevant.
#' Use with \code{\link{createRoutesFromElements}} and \code{\link{Route}}.
#'
#' @rdname createMemoryRouter
#' @param ... \code{\link{Route}} elements. Pass directly, or (optionally)
#'   wrapped in \code{\link{createRoutesFromElements}} to mirror the
#'   official React Router v7 API.
#' @return A createMemoryRouter component.
#' @export
createMemoryRouter <- function(...) {
  tag <- shiny.react::reactElement(
    module = "@/reactRouter",
    name = "CreateMemoryRouter",
    props = shiny.react::asProps(...),
    deps = reactRouterDependency()
  )
  class(tag) <- c("reactRouter", class(tag))
  tag
}

#' RouterProvider
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.RouterProvider.html}
#'
#' Renders a data router. Mirrors the React Router v7 composition pattern:
#' pass a router built with \code{\link{createHashRouter}},
#' \code{\link{createBrowserRouter}}, or \code{\link{createMemoryRouter}} to
#' the \code{router} argument.
#'
#' @rdname RouterProvider
#' @param router A router element produced by \code{\link{createHashRouter}},
#'   \code{\link{createBrowserRouter}}, or \code{\link{createMemoryRouter}}.
#' @param fallbackElement Element shown while the initial route's loader is
#'   resolving.
#' @return A RouterProvider component.
#' @export
RouterProvider <- function(router, fallbackElement = NULL) {
  tag <- shiny.react::reactElement(
    module = "@/reactRouter",
    name = "RouterProvider",
    props = shiny.react::asProps(
      router = router,
      fallbackElement = fallbackElement
    ),
    deps = reactRouterDependency()
  )
  class(tag) <- c("reactRouter", class(tag))
  tag
}
