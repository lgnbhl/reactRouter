#' @param into A component (HTML tag or \pkg{shiny.react}-based element)
#'   that will receive the hook data as the specified prop.
#' @param as Character. The name of the component's prop to inject the hook
#'   data into (by default \code{"children"} for text display, \code{"rows"} for
#'   a data grid, \code{"value"} for an input).
#' @param selector Character. Optional key to extract from the hook data object.
#'   If \code{NULL} (the default), the entire data is passed. Dotted paths
#'   like \code{"summary.title"} navigate nested objects.
#' @param render Optional \code{\link{JS}} function \code{(value) => ReactNode}
#'   used in place of \code{into}/\code{as}. Mirrors the native React Router
#'   pattern for cases where a single prop is not expressive enough (e.g.
#'   \code{JS("v => `${v.first} ${v.last}`")}).
#' @param ... Additional props to pass to the component.
#' @name hook-wrapper
#' @keywords internal
NULL

validateTarget <- function(label, into, render) {
  if (!is.null(render) && !inherits(render, "JS_EVAL")) {
    stop(
      sprintf(
        '%s(): `render` must be a JS() function, e.g. render = JS("v => v.name"). Got %s.',
        label,
        class(render)[1]
      ),
      call. = FALSE
    )
  }
  if (!is.null(render) && !is.null(into)) {
    stop(
      sprintf(
        '%s(): `render` and `into` are mutually exclusive — provide one or the other, not both.',
        label
      ),
      call. = FALSE
    )
  }
  if (is.null(render) && is.null(into)) {
    stop(
      sprintf(
        '%s(): provide either `into` (a component to inject the value into) or `render` (a JS() function that returns a React element).',
        label
      ),
      call. = FALSE
    )
  }
}

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

#' Await
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.Await.html}
#'
#' Renders \code{into} when a deferred loader promise resolves, injecting the
#' resolved value (or a \code{selector} from it) \code{as} a prop.
#' Use inside a \code{\link{Route}} whose \code{loader} returns an object
#' containing a promise (written via \code{\link{JS}}). In React Router v7,
#' simply return the object directly — no \code{defer()} wrapper is needed.
#'
#' @inheritParams hook-wrapper
#' @param resolveKey Character. The key in the loader's return value that holds
#'   the promise (e.g. if the loader returns \code{\{ data: promise \}},
#'   set \code{resolveKey = "data"}).
#' @param errorElement Element to render if the promise rejects.
#' @param fallback Element shown while the promise is pending. Defaults to a
#'   plain \code{"Loading\u2026"} span.
#'
#' @rdname Await
#' @export
Await <- function(
  into = NULL,
  as = "children",
  resolveKey,
  selector = NULL,
  render = NULL,
  errorElement = NULL,
  fallback = NULL,
  ...
) {
  validateTarget("Await", into, render)
  tag <- shiny.react::reactElement(
    module = "@/reactRouter",
    name = "Await",
    props = shiny.react::asProps(
      as = as,
      into = into,
      resolveKey = resolveKey,
      selector = selector,
      render = render,
      errorElement = errorElement,
      fallback = fallback,
      ...
    ),
    deps = reactRouterDependency()
  )
  class(tag) <- c("reactRouter", class(tag))
  tag
}

# Internal: build a React element that dispatches through the generic
# `UseHook` JSX component. Every simple hook wrapper delegates here.
useHookElement <- function(
  hook,
  into = NULL,
  render = NULL,
  ...,
  mapArray = FALSE,
  nullIfFalsy = FALSE
) {
  validateTarget(hook, into, render)
  tag <- shiny.react::reactElement(
    module = "@/reactRouter",
    name = "UseHook",
    props = shiny.react::asProps(
      hook = hook,
      mapArray = mapArray,
      nullIfFalsy = nullIfFalsy,
      into = into,
      render = render,
      ...
    ),
    deps = reactRouterDependency()
  )
  class(tag) <- c("reactRouter", class(tag))
  tag
}

#' useLoaderData
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.useLoaderData.html}
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
useLoaderData <- function(
  into = NULL,
  as = "children",
  selector = NULL,
  render = NULL,
  ...
) {
  useHookElement(
    hook = "useLoaderData",
    into = into,
    as = as,
    selector = selector,
    render = render,
    ...
  )
}

#' useActionData
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.useActionData.html}
#'
#' Calls the \code{useActionData()} hook and injects the result (or a
#' \code{selector} from it) \code{as} a prop of the \code{into} component.
#' Use inside a \code{\link{Route}} that has an \code{action}.
#'
#' @inheritParams hook-wrapper
#'
#' @rdname useActionData
#' @export
useActionData <- function(
  into = NULL,
  as = "children",
  selector = NULL,
  render = NULL,
  ...
) {
  useHookElement(
    hook = "useActionData",
    into = into,
    as = as,
    selector = selector,
    render = render,
    ...
  )
}

#' useLocation
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.useLocation.html}
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
useLocation <- function(
  into = NULL,
  as = "children",
  selector = NULL,
  render = NULL,
  ...
) {
  useHookElement(
    hook = "useLocation",
    into = into,
    as = as,
    selector = selector,
    render = render,
    ...
  )
}

#' useParams
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.useParams.html}
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
useParams <- function(
  into = NULL,
  as = "children",
  selector = NULL,
  render = NULL,
  ...
) {
  useHookElement(
    hook = "useParams",
    into = into,
    as = as,
    selector = selector,
    render = render,
    ...
  )
}

#' useNavigation
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.useNavigation.html}
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
useNavigation <- function(
  into = NULL,
  as = "children",
  selector = NULL,
  render = NULL,
  ...
) {
  useHookElement(
    hook = "useNavigation",
    into = into,
    as = as,
    selector = selector,
    render = render,
    ...
  )
}

#' useRouteLoaderData
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.useRouteLoaderData.html}
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
  into = NULL,
  as = "children",
  selector = NULL,
  render = NULL,
  routeId,
  ...
) {
  useHookElement(
    hook = "useRouteLoaderData",
    hookArg = routeId,
    into = into,
    as = as,
    selector = selector,
    render = render,
    ...
  )
}

#' useRouteError
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.useRouteError.html}
#'
#' Calls the \code{useRouteError()} hook and injects the result (or a
#' \code{selector} from it) \code{as} a prop of the \code{into} component.
#' Use inside the \code{errorElement} of a \code{\link{Route}}.
#'
#' @inheritParams hook-wrapper
#'
#' @rdname useRouteError
#' @export
useRouteError <- function(
  into = NULL,
  as = "children",
  selector = NULL,
  render = NULL,
  ...
) {
  useHookElement(
    hook = "useRouteError",
    nullIfFalsy = TRUE,
    into = into,
    as = as,
    selector = selector,
    render = render,
    ...
  )
}

#' useNavigationType
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.useNavigationType.html}
#'
#' Calls the \code{useNavigationType()} hook and injects the result
#' \code{as} a prop of the \code{into} component.
#' Returns one of \code{"POP"}, \code{"PUSH"}, or \code{"REPLACE"}.
#'
#' @inheritParams hook-wrapper
#'
#' @rdname useNavigationType
#' @export
useNavigationType <- function(
  into = NULL,
  as = "children",
  render = NULL,
  ...
) {
  useHookElement(
    hook = "useNavigationType",
    into = into,
    as = as,
    render = render,
    ...
  )
}

#' useMatch
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.useMatch.html}
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
useMatch <- function(
  into = NULL,
  as = "children",
  selector = NULL,
  render = NULL,
  pattern,
  ...
) {
  useHookElement(
    hook = "useMatch",
    hookArg = pattern,
    nullIfFalsy = TRUE,
    into = into,
    as = as,
    selector = selector,
    render = render,
    ...
  )
}

#' useMatches
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.useMatches.html}
#'
#' Calls the \code{useMatches()} hook and injects the result (or a
#' \code{selector} extracted from each match) \code{as} a prop of the
#' \code{into} component. Only works inside a data router.
#'
#' @inheritParams hook-wrapper
#'
#' @rdname useMatches
#' @export
useMatches <- function(
  into = NULL,
  as = "children",
  selector = NULL,
  render = NULL,
  ...
) {
  useHookElement(
    hook = "useMatches",
    mapArray = TRUE,
    into = into,
    as = as,
    selector = selector,
    render = render,
    ...
  )
}

#' useSearchParams
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.useSearchParams.html}
#'
#' Calls the \code{useSearchParams()} hook and injects the result
#' \code{as} a prop of the \code{into} component. Use the \code{param}
#' argument to extract a query parameter by name.
#'
#' Values are always returned as character vectors so that repeated keys
#' (e.g. \code{"?tag=a&tag=b"}) are preserved. When injected as
#' \code{"children"}, vectors are joined with \code{", "}; for custom
#' formatting, use \code{render}.
#'
#' @inheritParams hook-wrapper
#' @param param Character. Name of a single query parameter to extract.
#'   Returns a character vector of all values for that key (length 0 if
#'   absent, length 1+ otherwise). When \code{NULL}, returns a named list
#'   mapping each key to its vector of values.
#'
#' @rdname useSearchParams
#' @export
useSearchParams <- function(
  into = NULL,
  as = "children",
  param = NULL,
  render = NULL,
  ...
) {
  validateTarget("useSearchParams", into, render)
  tag <- shiny.react::reactElement(
    module = "@/reactRouter",
    name = "useSearchParams",
    props = shiny.react::asProps(
      as = as,
      into = into,
      param = param,
      render = render,
      ...
    ),
    deps = reactRouterDependency()
  )
  class(tag) <- c("reactRouter", class(tag))
  tag
}

#' useHref
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.useHref.html}
#'
#' Calls the \code{useHref()} hook and injects the resolved href string
#' \code{as} a prop of the \code{into} component.
#'
#' @inheritParams hook-wrapper
#' @param to Character. The path to resolve.
#'
#' @rdname useHref
#' @export
useHref <- function(into = NULL, as = "children", to, render = NULL, ...) {
  useHookElement(
    hook = "useHref",
    hookArg = to,
    into = into,
    as = as,
    render = render,
    ...
  )
}

#' useResolvedPath
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.useResolvedPath.html}
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
useResolvedPath <- function(
  into = NULL,
  as = "children",
  selector = NULL,
  render = NULL,
  to,
  ...
) {
  useHookElement(
    hook = "useResolvedPath",
    hookArg = to,
    into = into,
    as = as,
    selector = selector,
    render = render,
    ...
  )
}

#' useFetcher
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.useFetcher.html}
#'
#' Calls the \code{useFetcher()} hook and injects the result (or a
#' \code{selector} from it) \code{as} a prop of the \code{into} component.
#' Use to fetch data or submit forms without causing a navigation.
#' The fetcher object has \code{state} (\code{"idle"}/\code{"loading"}/\code{"submitting"}) and
#' \code{data} (the response from a loader or action).
#'
#' @inheritParams hook-wrapper
#' @param fetcherKey Character. Optional key to share a fetcher across
#'   components (e.g. \code{"my-fetcher"}).
#'
#' @rdname useFetcher
#' @export
useFetcher <- function(
  into = NULL,
  as = "children",
  selector = NULL,
  render = NULL,
  fetcherKey = NULL,
  ...
) {
  validateTarget("useFetcher", into, render)
  tag <- shiny.react::reactElement(
    module = "@/reactRouter",
    name = "useFetcher",
    props = shiny.react::asProps(
      as = as,
      into = into,
      selector = selector,
      render = render,
      fetcherKey = fetcherKey,
      ...
    ),
    deps = reactRouterDependency()
  )
  class(tag) <- c("reactRouter", class(tag))
  tag
}


#' useFetchers
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.useFetchers.html}
#'
#' Calls the \code{useFetchers()} hook and injects the result (or a
#' \code{selector} mapped over each fetcher) \code{as} a prop of the
#' \code{into} component. Returns an array of all active fetchers.
#' Useful for showing a global loading indicator.
#'
#' @inheritParams hook-wrapper
#'
#' @rdname useFetchers
#' @export
useFetchers <- function(
  into = NULL,
  as = "children",
  selector = NULL,
  render = NULL,
  ...
) {
  useHookElement(
    hook = "useFetchers",
    mapArray = TRUE,
    into = into,
    as = as,
    selector = selector,
    render = render,
    ...
  )
}

#' useRevalidator
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.useRevalidator.html}
#'
#' Calls the \code{useRevalidator()} hook and injects the result (or a
#' \code{selector} from it) \code{as} a prop of the \code{into} component.
#' Returns the revalidation \code{state} (\code{"idle"} or \code{"loading"}).
#' Useful for showing loading feedback during manual or polling revalidation.
#'
#' @inheritParams hook-wrapper
#'
#' @rdname useRevalidator
#' @export
useRevalidator <- function(
  into = NULL,
  as = "children",
  selector = "state",
  render = NULL,
  ...
) {
  useHookElement(
    hook = "useRevalidator",
    into = into,
    as = as,
    selector = selector,
    render = render,
    ...
  )
}

#' useBlocker
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.useBlocker.html}
#'
#' Calls the \code{useBlocker()} hook and injects the blocker's \code{state}
#' (or another \code{selector} field) \code{as} a prop of the \code{into}
#' component. Use to intercept navigation — e.g. warn the user about unsaved
#' changes before they leave a route.
#'
#' The blocker \code{state} is one of \code{"unblocked"} (default),
#' \code{"blocked"} (navigation intercepted), or \code{"proceeding"}
#' (user confirmed, navigation in progress).
#'
#' @inheritParams hook-wrapper
#' @param shouldBlock A \code{\link{JS}} function receiving
#'   \code{\{ currentLocation, nextLocation, historyAction \}} and returning
#'   \code{true} to block navigation or \code{false} to allow it.
#'   Pass \code{FALSE} to disable blocking entirely (the default).
#'
#' @rdname useBlocker
#' @export
useBlocker <- function(
  into = NULL,
  as = "children",
  selector = "state",
  render = NULL,
  shouldBlock = FALSE,
  ...
) {
  useHookElement(
    hook = "useBlocker",
    hookArg = shouldBlock,
    into = into,
    as = as,
    selector = selector,
    render = render,
    ...
  )
}

#' useNavigate
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.useNavigate.html}
#'
#' Calls the \code{useNavigate()} hook and passes the navigate function
#' to \code{render} (or injects it \code{as} a prop of \code{into}).
#' The navigate function has signature \code{navigate(to, options?)}, e.g.
#' \code{navigate("/about")} or \code{navigate(-1)} to go back.
#'
#' Because the hook returns a function (not a value), the \code{render}
#' form is the natural way to use it:
#' \preformatted{
#'   useNavigate(render = JS(
#'     "nav => <button onClick={() => nav('/about')}>Go</button>"
#'   ))
#' }
#'
#' @inheritParams hook-wrapper
#'
#' @rdname useNavigate
#' @export
useNavigate <- function(
  into = NULL,
  as = "children",
  render = NULL,
  ...
) {
  useHookElement(
    hook = "useNavigate",
    into = into,
    as = as,
    render = render,
    ...
  )
}

#' useSubmit
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.useSubmit.html}
#'
#' Calls the \code{useSubmit()} hook and passes the submit function to
#' \code{render} (or injects it \code{as} a prop of \code{into}).
#' The submit function has signature \code{submit(target, options?)} and
#' triggers a form submission (including calling the route's \code{action})
#' without requiring a \code{\link{Form}} element.
#' Only works inside a data router.
#'
#' @inheritParams hook-wrapper
#'
#' @examples
#' \dontrun{
#' useSubmit(render = JS(
#'   "submit => <button onClick={() =>
#'      submit({ intent: 'delete' }, { method: 'post' })
#'    }>Delete</button>"
#' ))
#' }
#'
#' @rdname useSubmit
#' @export
useSubmit <- function(
  into = NULL,
  as = "children",
  render = NULL,
  ...
) {
  useHookElement(
    hook = "useSubmit",
    into = into,
    as = as,
    render = render,
    ...
  )
}

#' redirect (loader/action helper)
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.redirect.html}
#'
#' Returns a \code{\link{JS}} loader function that redirects to \code{to}.
#' Pass as the \code{loader} argument of a \code{\link{Route}} to perform
#' an unconditional redirect — typically used for guard routes that always
#' send the user somewhere else.
#'
#' For conditional redirects inside a custom loader/action, use the global
#' \code{window.reactRouterHelpers.redirect(to)} from your own \code{JS()}
#' string, e.g.
#' \preformatted{
#'   loader = JS(
#'     "async () => { if (!authed()) return window.reactRouterHelpers.redirect('/login'); ... }"
#'   )
#' }
#'
#' The \code{data} and \code{replace} helpers are exposed on the same global
#' (\code{window.reactRouterHelpers.data}, \code{...replace}).
#'
#' @param to Character. Destination path.
#' @return A \code{\link{JS}} expression suitable for the \code{loader}
#'   argument of \code{\link{Route}}.
#'
#' @examples
#' \dontrun{
#' Route(path = "/old", loader = redirect("/new"), element = NULL)
#' }
#'
#' @rdname redirect
#' @export
redirect <- function(to) {
  if (!is.character(to) || length(to) != 1 || is.na(to)) {
    stop(
      "redirect(): `to` must be a single, non-NA character string.",
      call. = FALSE
    )
  }
  escaped <- gsub("\\\\", "\\\\\\\\", to)
  escaped <- gsub('"', '\\\\"', escaped)
  shiny.react::JS(sprintf(
    '() => window.reactRouterHelpers.redirect("%s")',
    escaped
  ))
}

#' useRoutes
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.useRoutes.html}
#'
#' Builds a route tree from \code{\link{Route}} children (or a plain object
#' \code{routes} array) and renders the matched route. The hook-based
#' equivalent of \code{\link{Routes}} / \code{createRoutesFromElements} for
#' code that prefers a configuration-as-data style. Must be called inside a
#' router (\code{\link{RouterProvider}}, \code{\link{HashRouter}}, etc.).
#'
#' @param ... \code{\link{Route}} elements describing the route tree.
#'   Ignored if \code{routes} is supplied.
#' @param routes Optional. A \code{\link{JS}} expression evaluating to a plain
#'   JavaScript array of route objects (e.g. \code{JS("[\{ path: '/', element: ... \}]")}),
#'   used in place of \code{Route()} children.
#'
#' @rdname useRoutes
#' @export
useRoutes <- function(..., routes = NULL) {
  tag <- shiny.react::reactElement(
    module = "@/reactRouter",
    name = "UseRoutes",
    props = shiny.react::asProps(..., routes = routes),
    deps = reactRouterDependency()
  )
  class(tag) <- c("reactRouter", class(tag))
  tag
}

#' useInRouterContext
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.useInRouterContext.html}
#'
#' Calls the \code{useInRouterContext()} hook and injects the boolean result
#' \code{as} a prop of the \code{into} component. Useful inside reusable
#' components that may be rendered with or without a surrounding router —
#' guard router-only logic with this check before calling other hooks.
#'
#' @inheritParams hook-wrapper
#'
#' @rdname useInRouterContext
#' @export
useInRouterContext <- function(
  into = NULL,
  as = "children",
  render = NULL,
  ...
) {
  useHookElement(
    hook = "useInRouterContext",
    into = into,
    as = as,
    render = render,
    ...
  )
}

#' useOutlet
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.useOutlet.html}
#'
#' Calls the \code{useOutlet()} hook and injects the matched child route's
#' element \code{as} a prop of the \code{into} component (or passes it to
#' \code{render}). Returns \code{NULL} when no child route matches — useful for
#' rendering a fallback inside a layout when the user is on the parent route.
#'
#' Differs from the \code{\link{Outlet}} component in that it returns the
#' element as a value, so you can branch on whether a child route is matched.
#'
#' @inheritParams hook-wrapper
#' @param context Optional value to expose to descendants via
#'   \code{\link{useOutletContext}}.
#'
#' @examples
#' \dontrun{
#' # In a layout route: render the matched child, or a fallback if on the
#' # parent route itself.
#' useOutlet(
#'   render = JS("o => o || <p>Pick a section from the menu.</p>")
#' )
#'
#' # Inject the matched outlet element as the body of a wrapping <section>.
#' useOutlet(into = shiny::tags$section(class = "page"))
#' }
#'
#' @rdname useOutlet
#' @export
useOutlet <- function(
  into = NULL,
  as = "children",
  render = NULL,
  context = NULL,
  ...
) {
  useHookElement(
    hook = "useOutlet",
    hookArg = context,
    nullIfFalsy = TRUE,
    into = into,
    as = as,
    render = render,
    ...
  )
}

#' useViewTransitionState
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.useViewTransitionState.html}
#'
#' Calls the \code{useViewTransitionState()} hook and injects the boolean
#' result \code{as} a prop of the \code{into} component. Returns \code{TRUE}
#' while a View Transitions API navigation toward \code{to} is in progress.
#' Pair with the \code{viewTransition} prop on \code{\link{Link}}/\code{\link{NavLink}}
#' to drive transition-aware styling.
#'
#' @inheritParams hook-wrapper
#' @param to Character. The destination path being transitioned to.
#' @param relative Optional character. Either \code{"route"} (default) or
#'   \code{"path"}.
#'
#' @rdname useViewTransitionState
#' @export
useViewTransitionState <- function(
  into = NULL,
  as = "children",
  render = NULL,
  to,
  relative = NULL,
  ...
) {
  validateTarget("useViewTransitionState", into, render)
  tag <- shiny.react::reactElement(
    module = "@/reactRouter",
    name = "useViewTransitionState",
    props = shiny.react::asProps(
      as = as,
      into = into,
      render = render,
      to = to,
      relative = relative,
      ...
    ),
    deps = reactRouterDependency()
  )
  class(tag) <- c("reactRouter", class(tag))
  tag
}

#' useLinkClickHandler
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.useLinkClickHandler.html}
#'
#' Calls the \code{useLinkClickHandler()} hook and exposes the returned click
#' handler function via \code{render} (or injects it \code{as} a prop of
#' \code{into}, e.g. \code{as = "onClick"}). Lets you build link-like
#' components that drive client-side navigation without using
#' \code{\link{Link}}.
#'
#' Because the hook returns a function, the \code{render} form is the natural
#' fit:
#' \preformatted{
#'   useLinkClickHandler(
#'     to = "/about",
#'     render = JS("h => <span onClick={h} role='link'>About</span>")
#'   )
#' }
#'
#' @inheritParams hook-wrapper
#' @param to Character. Destination path.
#' @param replace Optional boolean. Replace the current entry in the history
#'   stack instead of pushing a new one.
#' @param state Optional. State value to attach to the new location.
#' @param target Optional character. Anchor target (e.g. \code{"_blank"}).
#' @param preventScrollReset Optional boolean. If \code{TRUE}, do not reset
#'   scroll position on navigation.
#' @param relative Optional character. Either \code{"route"} (default) or
#'   \code{"path"}.
#'
#' @rdname useLinkClickHandler
#' @export
useLinkClickHandler <- function(
  into = NULL,
  as = "children",
  render = NULL,
  to,
  replace = NULL,
  state = NULL,
  target = NULL,
  preventScrollReset = NULL,
  relative = NULL,
  ...
) {
  validateTarget("useLinkClickHandler", into, render)
  tag <- shiny.react::reactElement(
    module = "@/reactRouter",
    name = "useLinkClickHandler",
    props = shiny.react::asProps(
      as = as,
      into = into,
      render = render,
      to = to,
      replace = replace,
      state = state,
      target = target,
      preventScrollReset = preventScrollReset,
      relative = relative,
      ...
    ),
    deps = reactRouterDependency()
  )
  class(tag) <- c("reactRouter", class(tag))
  tag
}

#' useOutletContext
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.useOutletContext.html}
#'
#' Calls the \code{useOutletContext()} hook and injects the context value
#' (or a \code{selector} from it) \code{as} a prop of the \code{into}
#' component. The context is whatever was passed to the parent route's
#' \code{Outlet(context = ...)} call.
#'
#' @inheritParams hook-wrapper
#'
#' @rdname useOutletContext
#' @export
useOutletContext <- function(
  into = NULL,
  as = "children",
  selector = NULL,
  render = NULL,
  ...
) {
  useHookElement(
    hook = "useOutletContext",
    into = into,
    as = as,
    selector = selector,
    render = render,
    ...
  )
}
