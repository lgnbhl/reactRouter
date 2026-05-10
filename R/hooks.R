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

#' Documentation template for hook wrappers whose value has no internal
#' structure to walk (scalars, booleans, or functions). Identical to
#' \code{hook-wrapper} except that \code{selector} is intentionally
#' omitted -- it would have nothing to walk.
#'
#' @param into A component (HTML tag or \pkg{shiny.react}-based element)
#'   that will receive the hook value as the specified prop.
#' @param as Character. The name of the component's prop to inject the hook
#'   value into. Defaults to \code{"children"}.
#' @param render Optional \code{\link{JS}} function \code{(value) => ReactNode}
#'   used in place of \code{into}/\code{as}.
#' @param ... Additional props to pass to the component.
#' @name hook-wrapper-noselector
#' @keywords internal
NULL

# For hooks whose value is a function (useNavigate, useSubmit,
# useLinkClickHandler): rendering a function as React `children` triggers
# "functions are not valid as a React child". Catch the common mistake at
# call time with a message that points the user at the right escape hatch.
#
# `onClickSafe` controls whether `as = "onClick"` is suggested. It is only
# safe for `useLinkClickHandler`, whose returned function takes a single
# MouseEvent argument and is therefore a drop-in onClick handler. For
# `useNavigate(to, options?)` and `useSubmit(target, options?)` the function
# expects positional args other than a MouseEvent — wiring the click event
# straight to it would call `navigate(MouseEvent)` and try to navigate to
# the event object. For those hooks we recommend `render = JS(...)` only.
validateFunctionTarget <- function(label, into, render, as, onClickSafe = FALSE) {
  validateTarget(label, into, render)
  if (!is.null(into) && identical(as, "children")) {
    if (onClickSafe) {
      stop(
        sprintf(
          '%s(): the hook returns a function, so it cannot be injected as `children`. ',
          label
        ),
        'Either pass `render = JS("fn => <a onClick={fn}>...</a>")`, ',
        'or set `as = "onClick"` (and pass a click target via `into`).',
        call. = FALSE
      )
    }
    stop(
      sprintf(
        '%s(): the hook returns a function (signature unlike a click handler), ',
        label
      ),
      'so it cannot be injected as `children` and must not be wired directly to ',
      '`as = "onClick"` (the click event would be passed as the function\'s ',
      'first argument). Use `render = JS("fn => <button onClick={() => fn(...)}>...</button>")` ',
      'so you can call the function with the right arguments.',
      call. = FALSE
    )
  }
  # Even when `as` is set explicitly, "onClick" is unsafe for these hooks:
  # the click event would be passed as the function's first positional arg.
  if (!onClickSafe && !is.null(into) && identical(as, "onClick")) {
    stop(
      sprintf(
        '%s(): wiring the hook function directly to `as = "onClick"` is unsafe ',
        label
      ),
      'because the click event would be passed as the first argument (the hook ',
      'expects e.g. `(to, options)`, not a MouseEvent). Use ',
      '`render = JS("fn => <button onClick={() => fn(...)}>...</button>")` instead.',
      call. = FALSE
    )
  }
}

validateTarget <- function(label, into, render) {
  if (!is.null(render) && !inherits(render, "JS_EVAL")) {
    stop(
      sprintf(
        '%s(): `render` must be a JS() function, e.g. render = JS("v => v.name"). Got value of class "%s" -- did you forget to wrap it in JS()?',
        label,
        class(render)[1]
      ),
      call. = FALSE
    )
  }
  if (!is.null(render) && !is.null(into)) {
    stop(
      sprintf(
        '%s(): `render` and `into` are mutually exclusive -- provide one or the other, not both.',
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

# Internal: build a reactElement from the package's "@/reactRouter" JSX
# module and tag it with the `reactRouter` S3 class so `print.reactRouter`
# picks it up. Used by every hook wrapper that doesn't go through the
# generic `UseHook` dispatcher.
customHookElement <- function(name, ...) {
  tag <- shiny.react::reactElement(
    module = "@/reactRouter",
    name = name,
    props = shiny.react::asProps(...),
    deps = reactRouterDependency()
  )
  class(tag) <- c("reactRouter", class(tag))
  tag
}

#' Await
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.Await.html}
#'
#' Renders \code{into} when a deferred loader promise resolves, injecting the
#' resolved value (or a \code{selector} from it) \code{as} a prop.
#' Use inside a \code{\link{Route}} whose \code{loader} returns an object
#' containing a promise (written via \code{\link{JS}}). In React Router v7,
#' simply return the object directly -- no \code{defer()} wrapper is needed.
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
  if (missing(resolveKey)) {
    stop('Await(): `resolveKey` is required (the key in the loader\'s return value that holds the promise).', call. = FALSE)
  }
  # Await has two shapes:
  #
  #   1. Target mode  — `into` or `render` is given. The resolved value is
  #      injected like any other hook (delegates to validateTarget).
  #   2. Children mode — neither `into` nor `render`, but children are
  #      passed via `...`. Those children are rendered directly inside
  #      <Await> so descendants can call useAsyncValue() / useAsyncError()
  #      against the same promise (matches React Router's native pattern).
  #
  # Only target mode runs the validator — children mode legitimately omits
  # both `into` and `render`.
  dots <- list(...)
  # Children are unnamed dots; named dots are extra props (forwarded but
  # not treated as children). asProps follows the same convention.
  dotNames <- names(dots)
  hasChildren <- if (is.null(dotNames)) length(dots) > 0 else any(!nzchar(dotNames))
  if (hasChildren && (!is.null(into) || !is.null(render))) {
    stop(
      "Await(): pass either `into`/`render` (target mode) or children ",
      "(children mode for descendant useAsyncValue()/useAsyncError()), ",
      "not both -- with `into`/`render` set, the children would be ignored.",
      call. = FALSE
    )
  }
  if (!(is.null(into) && is.null(render) && hasChildren)) {
    validateTarget("Await", into, render)
  }
  customHookElement(
    "Await",
    as = as,
    into = into,
    resolveKey = resolveKey,
    selector = selector,
    render = render,
    errorElement = errorElement,
    fallback = fallback,
    ...
  )
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
  customHookElement(
    "UseHook",
    hook = hook,
    mapArray = mapArray,
    nullIfFalsy = nullIfFalsy,
    into = into,
    render = render,
    ...
  )
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
  if (missing(routeId)) {
    stop('useRouteLoaderData(): `routeId` is required (the `id` of the Route to read loader data from).', call. = FALSE)
  }
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
#' @inheritParams hook-wrapper-noselector
#'
#' @rdname useNavigationType
#' @export
useNavigationType <- function(
  into = NULL,
  as = "children",
  # No `selector` arg: the upstream hook returns a scalar string, so there
  # is nothing to walk. If `selector` is ever added, also drop `mapArray =
  # FALSE` semantics from injectValue's path for this hook.
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
  if (missing(pattern)) {
    stop('useMatch(): `pattern` is required (a path pattern such as "/products/:id").', call. = FALSE)
  }
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
#' \strong{Reading vs. writing.} The upstream JS hook returns a tuple
#' \code{[searchParams, setSearchParams]}. This wrapper splits the two paths:
#' \itemize{
#'   \item \code{into} / \code{as} — \emph{read-only}. Receives the parsed
#'     params (or one \code{param}) and ignores the setter.
#'   \item \code{render} — receives both as \code{(params, setSearchParams)},
#'     so use this form when you need to update the URL programmatically:
#'     \preformatted{
#'   useSearchParams(render = JS(
#'     "(p, set) => <button onClick={() => set({tag:'b'})}>Filter</button>"
#'   ))
#'     }
#' }
#'
#' @inheritParams hook-wrapper
#' @param param Character. Name of a single query parameter to extract.
#'   Returns a character vector of all values for that key (length 0 if
#'   absent, length 1+ otherwise). When \code{NULL}, returns a named list
#'   mapping each key to its vector of values.
#'
#'   \strong{Empty vs. missing.} A missing key produces a length-0 vector,
#'   which renders as an empty string when injected with the default
#'   \code{as = "children"}. If you need to distinguish "absent" from
#'   "present-but-empty" (e.g. show a placeholder), use the \code{render}
#'   form and branch on \code{Array.isArray(v) && v.length === 0}, e.g.
#'   \code{render = JS("v => v.length ? v.join(', ') : <em>none</em>")}.
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
  customHookElement(
    "useSearchParams",
    as = as,
    into = into,
    param = param,
    render = render,
    ...
  )
}

#' useHref
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.useHref.html}
#'
#' Calls the \code{useHref()} hook and injects the resolved href string
#' \code{as} a prop of the \code{into} component.
#'
#' @inheritParams hook-wrapper-noselector
#' @param to Character. The path to resolve.
#'
#' @rdname useHref
#' @export
useHref <- function(into = NULL, as = "children", to, render = NULL, ...) {
  if (missing(to)) {
    stop('useHref(): `to` is required (the path to resolve).', call. = FALSE)
  }
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
  if (missing(to)) {
    stop('useResolvedPath(): `to` is required (the path to resolve).', call. = FALSE)
  }
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
#' @details
#' \code{selector} defaults to \code{"state"} so the default \code{into}/
#' \code{children} display shows a readable string (\code{"idle"} /
#' \code{"loading"} / \code{"submitting"}). The full fetcher object contains
#' methods (\code{submit}, \code{load}, \code{Form}) that would be silently
#' dropped by JSON serialization if the whole object were rendered as
#' children. To call those methods, use the \code{render = JS(...)} form,
#' which receives the full fetcher: \code{render = JS("f => <button onClick={() => f.load('/data')}>Reload</button>")}.
#'
#' @rdname useFetcher
#' @export
useFetcher <- function(
  into = NULL,
  as = "children",
  selector = "state",
  render = NULL,
  fetcherKey = NULL,
  ...
) {
  validateTarget("useFetcher", into, render)
  # Routed through `customHookElement` (the @/reactRouter JSX shim) rather
  # than the generic `useHookElement`/UseHook dispatcher because upstream
  # `useFetcher` takes an options object `{ key }`, not a positional arg,
  # and `{ key: undefined }` is not equivalent to passing nothing -- the
  # generic single-positional `hookArg` cannot express that.
  customHookElement(
    "useFetcher",
    as = as,
    into = into,
    selector = selector,
    render = render,
    fetcherKey = fetcherKey,
    ...
  )
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
#' component. Use to intercept navigation -- e.g. warn the user about unsaved
#' changes before they leave a route.
#'
#' The blocker \code{state} is one of \code{"unblocked"} (default),
#' \code{"blocked"} (navigation intercepted), or \code{"proceeding"}
#' (user confirmed, navigation in progress).
#'
#' @inheritParams hook-wrapper
#' @param shouldBlock Either \code{FALSE} (the default, disables blocking)
#'   or a \code{\link{JS}} function receiving
#'   \code{\{ currentLocation, nextLocation, historyAction \}} and returning
#'   \code{true} to block navigation or \code{false} to allow it.
#'   \strong{Must be a JS() expression}, not an R function -- R functions
#'   cannot be invoked from inside React Router's blocker callback.
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
#' @inheritParams hook-wrapper-noselector
#'
#' @rdname useNavigate
#' @export
useNavigate <- function(
  into = NULL,
  as = "children",
  render = NULL,
  ...
) {
  validateFunctionTarget("useNavigate", into, render, as)
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
#' Because the hook returns a function (not a value), the \code{into} form
#' is rarely useful here -- prefer \code{render = JS(...)} so you can call
#' the submit function from inside the rendered element.
#'
#' @inheritParams hook-wrapper-noselector
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
  validateFunctionTarget("useSubmit", into, render, as)
  useHookElement(
    hook = "useSubmit",
    into = into,
    as = as,
    render = render,
    ...
  )
}

#' useAsyncValue
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.useAsyncValue.html}
#'
#' Calls the \code{useAsyncValue()} hook and injects the resolved value (or a
#' \code{selector} from it) \code{as} a prop of the \code{into} component.
#' Must be rendered inside an \code{\link{Await}} that has been called in
#' \emph{children mode} (no \code{into} / \code{render} on \code{Await}) -- the
#' hook reads the value resolved by the closest \code{<Await>} ancestor.
#'
#' @inheritParams hook-wrapper
#'
#' @rdname useAsyncValue
#' @export
useAsyncValue <- function(
  into = NULL,
  as = "children",
  selector = NULL,
  render = NULL,
  ...
) {
  useHookElement(
    hook = "useAsyncValue",
    into = into,
    as = as,
    selector = selector,
    render = render,
    ...
  )
}

#' useAsyncError
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.useAsyncError.html}
#'
#' Calls the \code{useAsyncError()} hook and injects the rejection reason
#' (or a \code{selector} from it) \code{as} a prop of the \code{into}
#' component. Must be rendered inside the \code{errorElement} of an
#' \code{\link{Await}} so the hook can pick up the rejected promise's error.
#'
#' @inheritParams hook-wrapper
#'
#' @rdname useAsyncError
#' @export
useAsyncError <- function(
  into = NULL,
  as = "children",
  selector = NULL,
  render = NULL,
  ...
) {
  useHookElement(
    hook = "useAsyncError",
    nullIfFalsy = TRUE,
    into = into,
    as = as,
    selector = selector,
    render = render,
    ...
  )
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
  customHookElement("UseRoutes", ..., routes = routes)
}

#' useInRouterContext
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.useInRouterContext.html}
#'
#' Calls the \code{useInRouterContext()} hook and injects the boolean result
#' \code{as} a prop of the \code{into} component. Useful inside reusable
#' components that may be rendered with or without a surrounding router --
#' guard router-only logic with this check before calling other hooks.
#'
#' @inheritParams hook-wrapper-noselector
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
#' \code{render}). Returns \code{NULL} when no child route matches -- useful for
#' rendering a fallback inside a layout when the user is on the parent route.
#'
#' Differs from the \code{\link{Outlet}} component in that it returns the
#' element as a value, so you can branch on whether a child route is matched.
#'
#' @inheritParams hook-wrapper-noselector
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
#' @inheritParams hook-wrapper-noselector
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
  if (missing(to)) {
    stop('useViewTransitionState(): `to` is required (the destination path being transitioned to).', call. = FALSE)
  }
  validateTarget("useViewTransitionState", into, render)
  customHookElement(
    "useViewTransitionState",
    as = as,
    into = into,
    render = render,
    to = to,
    relative = relative,
    ...
  )
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
#' @inheritParams hook-wrapper-noselector
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
  if (missing(to)) {
    stop('useLinkClickHandler(): `to` is required (the destination path).', call. = FALSE)
  }
  validateFunctionTarget("useLinkClickHandler", into, render, as, onClickSafe = TRUE)
  customHookElement(
    "useLinkClickHandler",
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
  )
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
