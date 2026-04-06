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
#' @description \url{https://reactrouter.com/6.30.0/router-components/hash-router}
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
#' @description \url{https://reactrouter.com/6.30.0/router-components/browser-router}
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
#' @description \url{https://reactrouter.com/6.30.0/router-components/memory-router}
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
#' \url{https://reactrouter.com/6.30.0/components/route}
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
      when = "0.1.2",
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
#' @description \url{https://reactrouter.com/6.30.0/components/navigate}
#' @param ... Props to pass to element.
#' @return A Navigate component.
#' @export
Navigate <- component('Navigate')

#' NavLink
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
      when = "0.1.2",
      what = "Link(reloadDocument = 'default is now FALSE')",
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

#' Form
#' @rdname Form
#' @description \url{https://reactrouter.com/6.30.0/components/form}
#' @param ... Props to pass to element.
#' @return A Form component.
#' @export
Form <- component('Form')

#' createBrowserRouter
#'
#' \url{https://reactrouter.com/6.30.0/routers/create-browser-router}
#'
#' Creates a browser router using the data router API.
#' Use with \code{\link{createRoutesFromElements}} and \code{\link{Route}}.
#'
#' @rdname createBrowserRouter
#' @param ... \code{\link{Route}} elements, typically wrapped in
#'   \code{\link{createRoutesFromElements}}.
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
#' \url{https://reactrouter.com/6.30.0/routers/create-hash-router}
#'
#' Creates a hash router using the data router API.
#' Use with \code{\link{createRoutesFromElements}} and \code{\link{Route}}.
#'
#' @rdname createHashRouter
#' @param ... \code{\link{Route}} elements, typically wrapped in
#'   \code{\link{createRoutesFromElements}}.
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
#' \url{https://reactrouter.com/6.30.0/utils/create-routes-from-elements}
#'
#' Wraps \code{\link{Route}} elements for use with \code{\link{createBrowserRouter}},
#' \code{\link{createHashRouter}}, or \code{\link{createMemoryRouter}}.
#' The actual conversion from JSX elements to route objects happens on the
#' JavaScript side.
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
#' \url{https://reactrouter.com/6.30.0/routers/create-memory-router}
#'
#' Creates a memory router using the data router API. Routing state is kept
#' in memory and the browser URL is never read or modified, making it suitable
#' for static HTML pages (\code{file://}), Quarto documents, and embedded
#' widgets where the real URL is irrelevant.
#' Use with \code{\link{createRoutesFromElements}} and \code{\link{Route}}.
#'
#' @rdname createMemoryRouter
#' @param ... \code{\link{Route}} elements, typically wrapped in
#'   \code{\link{createRoutesFromElements}}.
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
#' \url{https://reactrouter.com/6.30.0/routers/router-provider}
#'
#' A unified wrapper around data routers. Use the \code{type} argument to
#' select the router variant: \code{"hash"} (default), \code{"memory"}, or
#' \code{"browser"}. Internally equivalent to \code{\link{createHashRouter}},
#' \code{\link{createMemoryRouter}}, or \code{\link{createBrowserRouter}}.
#'
#' @rdname RouterProvider
#' @param ... \code{\link{Route}} elements, typically via
#'   \code{\link{createRoutesFromElements}}.
#' @param type Character. One of \code{"hash"} (default), \code{"memory"},
#'   or \code{"browser"}.
#' @return A RouterProvider component.
#' @export
RouterProvider <- function(..., type = c("hash", "memory", "browser")) {
  type <- match.arg(type)
  tag <- shiny.react::reactElement(
    module = "@/reactRouter",
    name = "RouterProvider",
    props = shiny.react::asProps(..., type = type),
    deps = reactRouterDependency()
  )
  class(tag) <- c("reactRouter", class(tag))
  tag
}

#' ScrollRestoration
#'
#' \url{https://reactrouter.com/6.30.0/components/scroll-restoration}
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

#' Await
#'
#' \url{https://reactrouter.com/6.30.0/components/await}
#'
#' Renders \code{into} when a deferred loader promise resolves, injecting the
#' resolved value (or a \code{selector} from it) \code{as} a prop.
#' Use inside a \code{\link{Route}} whose \code{loader} returns a
#' \code{defer()} object (written via \code{\link{JS}}).
#'
#' @inheritParams hook-wrapper
#' @param resolveKey Character. The key in the loader's \code{defer()} return
#'   value that holds the promise (e.g. if the loader returns
#'   \code{defer(\{ data: promise \})}, set \code{resolveKey = "data"}).
#' @param errorElement Element to render if the promise rejects.
#' @param fallback Element shown while the promise is pending. Defaults to a
#'   plain \code{"Loading\u2026"} span.
#'
#' @rdname Await
#' @export
Await <- function(
  into,
  as = "children",
  resolveKey,
  selector = NULL,
  errorElement = NULL,
  fallback = NULL,
  ...
) {
  tag <- shiny.react::reactElement(
    module = "@/reactRouter",
    name = "Await",
    props = shiny.react::asProps(
      as = as,
      into = into,
      resolveKey = resolveKey,
      selector = selector,
      errorElement = errorElement,
      fallback = fallback,
      ...
    ),
    deps = reactRouterDependency()
  )
  class(tag) <- c("reactRouter", class(tag))
  tag
}

#' @param into A component (HTML tag or \pkg{shiny.react}-based element)
#'   that will receive the hook data as the specified prop.
#' @param as Character. The name of the component's prop to inject the hook
#'   data into (by default \code{"children"} for text display, \code{"rows"} for
#'   a data grid, \code{"value"} for an input).
#' @param selector Character. Optional key to extract from the hook data object.
#'   If \code{NULL} (the default), the entire data is passed.
#' @param ... Additional props to pass to the component.
#' @name hook-wrapper
#' @keywords internal
NULL

#' useLoaderData
#'
#' \url{https://reactrouter.com/6.30.0/hooks/use-loader-data}
#'
#' Calls the \code{useLoaderData()} hook and injects the result (or a
#' \code{selector} from it) \code{as} a prop of the \code{into} component.
#' Use inside a \code{\link{Route}} that has a \code{loader}.
#'
#' @inheritParams hook-wrapper
#'
#' @examples
#' \dontrun{
#' # Display a selector as text
#' useLoaderData(tags$h3(), selector = "name")
#'
#' # Pass an array to a data grid
#' useLoaderData(
#'   muiDataGrid::DataGrid(columns = JS("[
#'     { field: 'name', headerName: 'Name', flex: 1 }
#'   ]")),
#'   as = "rows",
#'   selector = "people"
#' )
#' }
#'
#' @rdname useLoaderData
#' @export
useLoaderData <- function(into, as = "children", selector = NULL, ...) {
  tag <- shiny.react::reactElement(
    module = "@/reactRouter",
    name = "useLoaderData",
    props = shiny.react::asProps(
      as = as,
      into = into,
      selector = selector,
      ...
    ),
    deps = reactRouterDependency()
  )
  class(tag) <- c("reactRouter", class(tag))
  tag
}

#' useActionData
#'
#' \url{https://reactrouter.com/6.30.0/hooks/use-action-data}
#'
#' Calls the \code{useActionData()} hook and injects the result (or a
#' \code{selector} from it) \code{as} a prop of the \code{into} component.
#' Use inside a \code{\link{Route}} that has an \code{action}.
#'
#' @inheritParams hook-wrapper
#'
#' @rdname useActionData
#' @export
useActionData <- function(into, as = "children", selector = NULL, ...) {
  tag <- shiny.react::reactElement(
    module = "@/reactRouter",
    name = "useActionData",
    props = shiny.react::asProps(
      as = as,
      into = into,
      selector = selector,
      ...
    ),
    deps = reactRouterDependency()
  )
  class(tag) <- c("reactRouter", class(tag))
  tag
}

#' useLocation
#'
#' \url{https://reactrouter.com/6.30.0/utils/location}
#'
#' Calls the \code{useLocation()} hook and injects the result (or a
#' \code{selector} from it) \code{as} a prop of the \code{into} component.
#' Available selectors: \code{pathname}, \code{search}, \code{hash},
#' \code{state}, \code{key}.
#'
#' @inheritParams hook-wrapper
#'
#' @rdname useLocation
#' @export
useLocation <- function(into, as = "children", selector = NULL, ...) {
  tag <- shiny.react::reactElement(
    module = "@/reactRouter",
    name = "useLocation",
    props = shiny.react::asProps(
      as = as,
      into = into,
      selector = selector,
      ...
    ),
    deps = reactRouterDependency()
  )
  class(tag) <- c("reactRouter", class(tag))
  tag
}

#' useParams
#'
#' \url{https://reactrouter.com/6.30.0/hooks/use-params}
#'
#' Calls the \code{useParams()} hook and injects the result (or a
#' \code{selector} from it) \code{as} a prop of the \code{into} component.
#' Returns the dynamic parameters from the current URL matched by the
#' \code{\link{Route}} path pattern.
#'
#' @inheritParams hook-wrapper
#'
#' @rdname useParams
#' @export
useParams <- function(into, as = "children", selector = NULL, ...) {
  tag <- shiny.react::reactElement(
    module = "@/reactRouter",
    name = "useParams",
    props = shiny.react::asProps(
      as = as,
      into = into,
      selector = selector,
      ...
    ),
    deps = reactRouterDependency()
  )
  class(tag) <- c("reactRouter", class(tag))
  tag
}

#' useNavigation
#'
#' \url{https://reactrouter.com/6.30.0/hooks/use-navigation}
#'
#' Calls the \code{useNavigation()} hook and injects the result (or a
#' \code{selector} from it) \code{as} a prop of the \code{into} component.
#' Returns the current navigation state: \code{"idle"}, \code{"loading"},
#' or \code{"submitting"}. Only works inside a data router.
#'
#' @inheritParams hook-wrapper
#'
#' @rdname useNavigation
#' @export
useNavigation <- function(into, as = "children", selector = NULL, ...) {
  tag <- shiny.react::reactElement(
    module = "@/reactRouter",
    name = "useNavigation",
    props = shiny.react::asProps(
      as = as,
      into = into,
      selector = selector,
      ...
    ),
    deps = reactRouterDependency()
  )
  class(tag) <- c("reactRouter", class(tag))
  tag
}

#' useRouteLoaderData
#'
#' \url{https://reactrouter.com/6.30.0/hooks/use-route-loader-data}
#'
#' Calls the \code{useRouteLoaderData()} hook and injects the result (or a
#' \code{selector} from it) \code{as} a prop of the \code{into} component.
#' Accesses loader data from any route by its \code{routeId}.
#' Only works inside a data router.
#'
#' @inheritParams hook-wrapper
#' @param routeId Character. The route ID to fetch loader data from.
#'
#' @rdname useRouteLoaderData
#' @export
useRouteLoaderData <- function(
  into,
  as = "children",
  selector = NULL,
  routeId,
  ...
) {
  tag <- shiny.react::reactElement(
    module = "@/reactRouter",
    name = "useRouteLoaderData",
    props = shiny.react::asProps(
      as = as,
      into = into,
      selector = selector,
      routeId = routeId,
      ...
    ),
    deps = reactRouterDependency()
  )
  class(tag) <- c("reactRouter", class(tag))
  tag
}

#' useRouteError
#'
#' \url{https://reactrouter.com/6.30.0/hooks/use-route-error}
#'
#' Calls the \code{useRouteError()} hook and injects the result (or a
#' \code{selector} from it) \code{as} a prop of the \code{into} component.
#' Use inside the \code{errorElement} of a \code{\link{Route}}.
#'
#' @inheritParams hook-wrapper
#'
#' @rdname useRouteError
#' @export
useRouteError <- function(into, as = "children", selector = NULL, ...) {
  tag <- shiny.react::reactElement(
    module = "@/reactRouter",
    name = "useRouteError",
    props = shiny.react::asProps(
      as = as,
      into = into,
      selector = selector,
      ...
    ),
    deps = reactRouterDependency()
  )
  class(tag) <- c("reactRouter", class(tag))
  tag
}

#' useNavigationType
#'
#' \url{https://reactrouter.com/6.30.0/hooks/use-navigation-type}
#'
#' Calls the \code{useNavigationType()} hook and injects the result
#' \code{as} a prop of the \code{into} component.
#' Returns one of \code{"POP"}, \code{"PUSH"}, or \code{"REPLACE"}.
#'
#' @param into A component that will receive the value.
#' @param as Character. The name of the component's prop to inject into.
#' @param ... Additional props to pass to the component.
#'
#' @rdname useNavigationType
#' @export
useNavigationType <- function(into, as = "children", ...) {
  tag <- shiny.react::reactElement(
    module = "@/reactRouter",
    name = "useNavigationType",
    props = shiny.react::asProps(as = as, into = into, ...),
    deps = reactRouterDependency()
  )
  class(tag) <- c("reactRouter", class(tag))
  tag
}

#' useMatch
#'
#' \url{https://reactrouter.com/6.30.0/hooks/use-match}
#'
#' Calls the \code{useMatch()} hook and injects the result (or a
#' \code{selector} from it) \code{as} a prop of the \code{into} component.
#' Returns \code{NULL} if no match.
#'
#' @inheritParams hook-wrapper
#' @param pattern Character. The path pattern to match against
#'   (e.g. \code{"/products/:id"}).
#'
#' @rdname useMatch
#' @export
useMatch <- function(into, as = "children", selector = NULL, pattern, ...) {
  tag <- shiny.react::reactElement(
    module = "@/reactRouter",
    name = "useMatch",
    props = shiny.react::asProps(
      as = as,
      into = into,
      selector = selector,
      pattern = pattern,
      ...
    ),
    deps = reactRouterDependency()
  )
  class(tag) <- c("reactRouter", class(tag))
  tag
}

#' useMatches
#'
#' \url{https://reactrouter.com/6.30.0/hooks/use-matches}
#'
#' Calls the \code{useMatches()} hook and injects the result (or a
#' \code{selector} extracted from each match) \code{as} a prop of the
#' \code{into} component. Only works inside a data router.
#'
#' @inheritParams hook-wrapper
#'
#' @rdname useMatches
#' @export
useMatches <- function(into, as = "children", selector = NULL, ...) {
  tag <- shiny.react::reactElement(
    module = "@/reactRouter",
    name = "useMatches",
    props = shiny.react::asProps(
      as = as,
      into = into,
      selector = selector,
      ...
    ),
    deps = reactRouterDependency()
  )
  class(tag) <- c("reactRouter", class(tag))
  tag
}

#' useSearchParams
#'
#' \url{https://reactrouter.com/6.30.0/hooks/use-search-params}
#'
#' Calls the \code{useSearchParams()} hook and injects the result
#' \code{as} a prop of the \code{into} component. Use the \code{param}
#' argument to extract a single query parameter by name.
#'
#' @param into A component that will receive the value.
#' @param as Character. The name of the component's prop to inject into.
#' @param param Character. Optional name of a single query parameter
#'   to extract (e.g. \code{"q"}). If \code{NULL}, all params are
#'   passed as a named list.
#' @param ... Additional props to pass to the component.
#'
#' @rdname useSearchParams
#' @export
useSearchParams <- function(into, as = "children", param = NULL, ...) {
  tag <- shiny.react::reactElement(
    module = "@/reactRouter",
    name = "useSearchParams",
    props = shiny.react::asProps(
      as = as,
      into = into,
      param = param,
      ...
    ),
    deps = reactRouterDependency()
  )
  class(tag) <- c("reactRouter", class(tag))
  tag
}

#' useHref
#'
#' \url{https://reactrouter.com/6.30.0/hooks/use-href}
#'
#' Calls the \code{useHref()} hook and injects the resolved href string
#' \code{as} a prop of the \code{into} component.
#'
#' @param to Character. The path to resolve.
#' @param into A component that will receive the value.
#' @param as Character. The name of the component's prop to inject into.
#' @param ... Additional props to pass to the component.
#'
#' @rdname useHref
#' @export
useHref <- function(into, as = "children", to, ...) {
  tag <- shiny.react::reactElement(
    module = "@/reactRouter",
    name = "useHref",
    props = shiny.react::asProps(as = as, into = into, to = to, ...),
    deps = reactRouterDependency()
  )
  class(tag) <- c("reactRouter", class(tag))
  tag
}

#' useResolvedPath
#'
#' \url{https://reactrouter.com/6.30.0/hooks/use-resolved-path}
#'
#' Calls the \code{useResolvedPath()} hook and injects the result (or a
#' \code{selector} from it) \code{as} a prop of the \code{into} component.
#' Returns \code{pathname}, \code{search}, and \code{hash}.
#'
#' @inheritParams hook-wrapper
#' @param to Character. The path to resolve.
#'
#' @rdname useResolvedPath
#' @export
useResolvedPath <- function(into, as = "children", selector = NULL, to, ...) {
  tag <- shiny.react::reactElement(
    module = "@/reactRouter",
    name = "useResolvedPath",
    props = shiny.react::asProps(
      as = as,
      into = into,
      selector = selector,
      to = to,
      ...
    ),
    deps = reactRouterDependency()
  )
  class(tag) <- c("reactRouter", class(tag))
  tag
}
