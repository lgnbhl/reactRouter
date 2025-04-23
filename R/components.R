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
  function(...) shiny.react::reactElement(
    module = module,
    name = name,
    props = shiny.react::asProps(...),
    deps = reactRouterDependency()
  )
}

#' HashRouter
#' @rdname HashRouter
#' @description \url{https://reactrouter.com/6.30.0/router-components/hash-router}
#' @param ... Props to pass to element.
#' @return A HashRouter component.
#' @export
HashRouter <- component('HashRouter')

#' MemoryRouter
#' @rdname MemoryRouter
#' @description \url{https://reactrouter.com/6.30.0/router-components/memory-router}
#' @param ... Props to pass to element.
#' @return A MemoryRouter component.
#' @export
MemoryRouter <- component('MemoryRouter')

#' Route
#' @rdname Route
#' @description \url{https://reactrouter.com/6.30.0/components/route}
#' @param ... Props to pass to element.
#' @return A Route component.
#' @export
Route <- component('Route')

#' Link
#' @rdname Link
#' @description \url{https://reactrouter.com/6.30.0/components/link}
#' @param ... Props to pass to element.
#' @return A Link component.
#' @export
Link <- component('Link')

#' Navigate
#' @rdname Navigate
#' @description \url{https://reactrouter.com/6.30.0/components/navigate}
#' @param ... Props to pass to element.
#' @return A Navigate component.
#' @export
Navigate <- component('Navigate')

#' NavLink
#' @rdname NavLink
#' @description \url{https://reactrouter.com/6.30.0/components/nav-link}
#' @param ... Props to pass to element.
#' @return A NavLink component.
#' @export
NavLink <- component('NavLink')

#' Outlet
#' @rdname Outlet
#' @description \url{https://reactrouter.com/6.30.0/components/outlet}
#' @param ... Props to pass to element.
#' @return A Outlet component.
#' @export
Outlet <- component('Outlet')

#' Routes
#' @rdname Routes
#' @description \url{https://reactrouter.com/6.30.0/components/routes}
#' @param ... Props to pass to element.
#' @return A Routes component.
#' @export
Routes <- component('Routes')
