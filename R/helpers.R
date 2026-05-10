#' JavaScript helpers exposed on \code{window.jsmodule['@/reactRouter'].helpers}
#'
#' For convenience, the package exposes a curated set of React Router v7
#' utility functions under \code{window.jsmodule['@/reactRouter'].helpers}
#' so user-authored \code{\link{JS}} loaders, actions, and render callbacks
#' can call them without reaching into webpack internals. The same names are
#' available as on the JS side of React Router itself.
#'
#' Scoped under the \pkg{shiny.react} \code{jsmodule} registry rather than
#' \code{window} so the package never adds a top-level global to the host
#' page. A short alias is the only ergonomic cost:
#' \preformatted{
#'   loader = JS("async () => {
#'     const { redirect } = window.jsmodule['@/reactRouter'].helpers;
#'     if (!await ok()) return redirect('/login');
#'     return { ok: true };
#'   }")
#' }
#'
#' \strong{Loader/action response helpers}
#' \itemize{
#'   \item \code{redirect(to, init?)} -- client-side navigation redirect.
#'   \item \code{replace(to, init?)} -- redirect that replaces the history entry.
#'   \item \code{redirectDocument(to)} -- full document reload redirect.
#'   \item \code{data(value, init?)} -- attach status/headers to a payload.
#' }
#'
#' \strong{Path / URL utilities}
#' \itemize{
#'   \item \code{generatePath(path, params)} -- build a URL from a pattern.
#'   \item \code{matchPath(pattern, pathname)} -- match a pathname.
#'   \item \code{matchRoutes(routes, location, basename?)} -- match a route
#'     tree against a location.
#'   \item \code{resolvePath(to, fromPathname?)} -- resolve a relative path.
#'   \item \code{parsePath(path)} -- split into \code{pathname/search/hash}.
#'   \item \code{createPath(parts)} -- inverse of \code{parsePath}.
#'   \item \code{createSearchParams(init)} -- build a \code{URLSearchParams}.
#' }
#'
#' These run in the browser only (inside \code{\link{JS}} loader/action code).
#' For R-side construction of a \code{Link()} \code{to} value from data, use
#' base R: \code{paste0("/users/", utils::URLencode(id, reserved = TRUE))}.
#'
#' \strong{Error helpers}
#' \itemize{
#'   \item \code{isRouteErrorResponse(error)} -- type guard intended for use
#'     inside an \code{errorElement} alongside \code{\link{useRouteError}};
#'     returns \code{true} when the error came from a thrown
#'     \code{Response} (e.g. \code{throw new Response(..., { status: 404 })}).
#' }
#'
#' These are the JavaScript implementations from \code{react-router-dom}.
#'
#' @examples
#' \dontrun{
#' # Conditional redirect inside a custom loader.
#' Route(
#'   path = "/admin",
#'   loader = JS("async () => {
#'     const { redirect } = window.jsmodule['@/reactRouter'].helpers;
#'     const ok = await checkAuth();
#'     if (!ok) return redirect('/login');
#'     return { ok: true };
#'   }"),
#'   element = useLoaderData(tags$pre())
#' )
#'
#' # Branch on whether the route error is a Response.
#' Route(
#'   path = "/items/:id",
#'   loader = JS("async ({ params }) => {
#'     const r = await fetch('/api/items/' + params.id);
#'     if (!r.ok) throw new Response('Not found', { status: 404 });
#'     return r.json();
#'   }"),
#'   errorElement = useRouteError(
#'     render = JS(
#'       "e => window.jsmodule['@/reactRouter'].helpers.isRouteErrorResponse(e)" +
#'       " ? <p>HTTP {e.status}</p> : <p>Unknown error</p>"
#'     )
#'   ),
#'   element = useLoaderData(tags$pre())
#' )
#' }
#'
#' @name reactRouterHelpers
#' @keywords internal
NULL

# Internal: JS expression that resolves to the package's helpers namespace.
# All R-side `redirect()`, `replaceResponse()`, etc. emit JS strings that
# look up helpers through this path so the package never adds anything to
# the global `window` object — see ?reactRouterHelpers.
HELPERS_JS <- "window.jsmodule['@/reactRouter'].helpers"

# Internal: produce a JavaScript string literal (including the surrounding
# quotes) for an R string. Delegates to jsonlite for full escaping of control
# characters, unicode line separators, and `</script>`.
jsLiteral <- function(x) {
  as.character(jsonlite::toJSON(x, auto_unbox = TRUE))
}

# Internal: reject URL schemes that can execute code when used as a redirect
# target (javascript:, data:, vbscript:). Allows everything else, including
# absolute http(s) URLs and root-relative paths.
assertSafeRedirectTarget <- function(fn, to) {
  if (!is.character(to) || length(to) != 1 || is.na(to)) {
    stop(
      sprintf(
        "%s(): `to` must be a single, non-NA character string.",
        fn
      ),
      call. = FALSE
    )
  }
  if (grepl("^\\s*(javascript|data|vbscript):", to, ignore.case = TRUE)) {
    stop(
      sprintf(
        "%s(): refusing unsafe URL scheme in `to` = %s. ",
        fn,
        deparse(to)
      ),
      call. = FALSE
    )
  }
  # Protocol-relative URLs (//host/...) inherit the page's scheme and send
  # the user off-origin. Safe by default: reject. Callers wanting a
  # cross-origin absolute URL can spell out the full https:// form.
  if (grepl("^\\s*//", to)) {
    stop(
      sprintf(
        "%s(): refusing protocol-relative URL in `to` = %s. ",
        fn,
        deparse(to)
      ),
      "Use a full https:// URL if you really want a cross-origin redirect.",
      call. = FALSE
    )
  }
}

#' redirect (loader/action helper)
#'
#' \url{https://reactrouter.com/api/utils/redirect}
#'
#' Returns a \code{\link{JS}} loader function that redirects to \code{to}.
#' Pass as the \code{loader} argument of a \code{\link{Route}} to perform
#' an unconditional redirect -- typically used for guard routes that always
#' send the user somewhere else.
#'
#' \strong{Security:} \code{to} must be a trusted, package-author-controlled
#' string. \code{javascript:}, \code{data:}, and \code{vbscript:} URL schemes
#' are rejected. If you build \code{to} from user-supplied input, validate it
#' yourself before passing it in -- never round-trip untrusted strings through
#' \code{redirect()} into a navigation.
#'
#' For conditional redirects inside a custom loader/action, call
#' \code{window.jsmodule['@/reactRouter'].helpers.redirect(to)} from your own
#' \code{JS()} string, e.g.
#' \preformatted{
#'   loader = JS(
#'     "async () => {
#'        const { redirect } = window.jsmodule['@/reactRouter'].helpers;
#'        if (!authed()) return redirect('/login'); ...
#'      }"
#'   )
#' }
#'
#' The \code{data}, \code{replace}, and \code{redirectDocument} helpers are
#' exposed on the same namespace.
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
  assertSafeRedirectTarget("redirect", to)
  shiny.react::JS(sprintf(
    '() => %s.redirect(%s)',
    HELPERS_JS,
    jsLiteral(to)
  ))
}

#' replaceResponse (loader/action helper)
#'
#' \url{https://reactrouter.com/api/utils/replace}
#'
#' Returns a \code{\link{JS}} loader function that performs a \emph{replace}
#' navigation to \code{to} -- same as \code{\link{redirect}}, but the new
#' entry replaces the current one in the history stack instead of pushing
#' a new one. Use for "alias" routes where the original URL should not
#' remain in the user's back-history.
#'
#' Renamed from \code{replace()} to avoid masking \code{base::replace}.
#' This mirrors the \code{dataResponse()} naming for the same reason.
#'
#' For conditional replacements inside a custom loader/action, call
#' \code{window.jsmodule['@/reactRouter'].helpers.replace(to)} from your own
#' \code{JS()} string.
#'
#' @param to Character. Destination path.
#' @return A \code{\link{JS}} expression suitable for the \code{loader}
#'   argument of \code{\link{Route}}.
#'
#' @examples
#' \dontrun{
#' Route(path = "/legacy", loader = replaceResponse("/new"), element = NULL)
#' }
#'
#' @rdname replaceResponse
#' @export
replaceResponse <- function(to) {
  assertSafeRedirectTarget("replaceResponse", to)
  shiny.react::JS(sprintf(
    '() => %s.replace(%s)',
    HELPERS_JS,
    jsLiteral(to)
  ))
}

#' redirectDocument (loader/action helper)
#'
#' \url{https://reactrouter.com/api/utils/redirectDocument}
#'
#' Returns a \code{\link{JS}} loader function that performs a \emph{document}
#' redirect to \code{to} -- a full page reload, as opposed to the client-side
#' navigation that \code{\link{redirect}} performs. Use when navigating to a
#' URL outside the router's control (e.g. a server-rendered page) so the
#' browser fully unloads the SPA.
#'
#' For conditional document redirects inside a custom loader/action, call
#' \code{window.jsmodule['@/reactRouter'].helpers.redirectDocument(to)} from
#' your own \code{JS()} string.
#'
#' @param to Character. Destination path or absolute URL.
#' @return A \code{\link{JS}} expression suitable for the \code{loader}
#'   argument of \code{\link{Route}}.
#'
#' @examples
#' \dontrun{
#' Route(
#'   path = "/docs",
#'   loader = redirectDocument("/static/docs/index.html"),
#'   element = NULL
#' )
#' }
#'
#' @rdname redirectDocument
#' @export
redirectDocument <- function(to) {
  assertSafeRedirectTarget("redirectDocument", to)
  shiny.react::JS(sprintf(
    '() => %s.redirectDocument(%s)',
    HELPERS_JS,
    jsLiteral(to)
  ))
}

#' dataResponse (loader/action helper)
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.data.html}
#'
#' Returns a \code{\link{JS}} loader function that resolves to a React Router
#' \code{data()} response -- a thin wrapper that lets you attach an HTTP
#' \code{status}, \code{statusText}, and/or \code{headers} alongside the
#' loader/action payload while still exposing \code{value} via
#' \code{\link{useLoaderData}} / \code{\link{useActionData}}.
#'
#' Use the R helper for static loaders that always return the same value plus
#' status. For values computed inside a custom loader/action, call
#' \code{window.jsmodule['@/reactRouter'].helpers.data(value, init)} directly
#' in your \code{JS()} string, e.g.
#' \preformatted{
#'   loader = JS("async () => {
#'     const { data } = window.jsmodule['@/reactRouter'].helpers;
#'     const rows = await fetchRows();
#'     return data(\{ rows \}, \{ status: 200 \});
#'   }")
#' }
#'
#' @param value The payload to expose via \code{useLoaderData()} /
#'   \code{useActionData()}. Either an R object (list, vector, data.frame --
#'   serialized to JSON), or a \code{\link{JS}} expression for a JavaScript
#'   value.
#' @param init Optional. Either a list with \code{status} (integer),
#'   \code{statusText} (character) and/or \code{headers} (named list), or a
#'   \code{\link{JS}} expression evaluating to such an object.
#' @return A \code{\link{JS}} expression suitable for the \code{loader} or
#'   \code{action} argument of \code{\link{Route}}.
#'
#' @examples
#' \dontrun{
#' Route(
#'   path = "/profile",
#'   loader = dataResponse(
#'     list(name = "Ada", role = "Engineer"),
#'     init = list(status = 200)
#'   ),
#'   element = useLoaderData(tags$pre())
#' )
#' }
#'
#' @name dataResponse
#' @export
dataResponse <- function(value, init = NULL) {
  if (missing(value)) {
    stop(
      "dataResponse(): `value` is required -- pass the payload that ",
      "useLoaderData()/useActionData() should expose. For an empty body, ",
      "pass NULL explicitly.",
      call. = FALSE
    )
  }
  serialize <- function(x) {
    if (inherits(x, "JS_EVAL")) {
      return(as.character(x))
    }
    jsonlite::toJSON(x, auto_unbox = TRUE, null = "null", na = "null")
  }
  # Surface common shape mistakes in `init` at call site, rather than as a
  # confusing browser-side error from React Router's data() helper.
  if (!is.null(init) && !inherits(init, "JS_EVAL")) {
    checkmate::assert_list(init, names = "named", .var.name = "init")
    allowed <- c("status", "statusText", "headers")
    bad <- setdiff(names(init), allowed)
    if (length(bad)) {
      stop(
        sprintf(
          "dataResponse(): unknown `init` field(s): %s. Allowed: %s.",
          paste(bad, collapse = ", "),
          paste(allowed, collapse = ", ")
        ),
        call. = FALSE
      )
    }
    if (!is.null(init$status)) {
      checkmate::assert_int(
        init$status,
        lower = 100,
        upper = 599,
        .var.name = "init$status"
      )
    }
    if (!is.null(init$statusText)) {
      checkmate::assert_string(init$statusText, .var.name = "init$statusText")
    }
    if (!is.null(init$headers)) {
      # Headers can be a named list/character vector; both serialize to a
      # plain JS object that the Headers constructor accepts.
      if (
        !(is.list(init$headers) || is.character(init$headers)) ||
          is.null(names(init$headers)) ||
          any(!nzchar(names(init$headers)))
      ) {
        stop(
          "dataResponse(): `init$headers` must be a fully named list or ",
          "character vector (e.g. list(`Content-Type` = \"application/json\")).",
          call. = FALSE
        )
      }
    }
  }
  valueJS <- serialize(value)
  initStr <- if (!is.null(init)) paste0(", ", serialize(init)) else ""
  shiny.react::JS(sprintf(
    "() => %s.data(%s%s)",
    HELPERS_JS,
    valueJS,
    initStr
  ))
}

#' isRouteErrorResponse
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.isRouteErrorResponse.html}
#'
#' Returns a \code{\link{JS}} reference to the \code{isRouteErrorResponse}
#' type guard. Use it inside an \code{errorElement} render callback to branch
#' on whether the error came from a thrown \code{Response}
#' (e.g. \code{throw new Response(..., \{ status: 404 \})}) or from arbitrary
#' code. Pair with \code{\link{useRouteError}}.
#'
#' Calling \code{isRouteErrorResponse()} from R returns a \code{\link{JS}}
#' expression that evaluates, in the browser, to the upstream
#' \code{isRouteErrorResponse} function. Interpolate it inside the
#' \code{render} string of \code{useRouteError()} as shown below.
#'
#' For convenience, the same function is also reachable inside any
#' user-authored \code{\link{JS}} string as
#' \code{window.jsmodule['@/reactRouter'].helpers.isRouteErrorResponse}.
#'
#' @return A \code{\link{JS}} expression evaluating to the
#'   \code{isRouteErrorResponse} function reference.
#'
#' @examples
#' \dontrun{
#' useRouteError(render = JS(paste0(
#'   "e => ", isRouteErrorResponse(),
#'   "(e) ? <p>HTTP {e.status}</p> : <p>Unknown error</p>"
#' )))
#' }
#'
#' @rdname isRouteErrorResponse
#' @export
isRouteErrorResponse <- function() {
  shiny.react::JS(paste0(HELPERS_JS, ".isRouteErrorResponse"))
}
