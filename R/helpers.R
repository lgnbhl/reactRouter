#' JavaScript helpers exposed on \code{window.reactRouterHelpers}
#'
#' For convenience, the package exposes a curated set of React Router v7
#' utility functions on the global \code{window.reactRouterHelpers} so
#' user-authored \code{\link{JS}} loaders, actions, and render callbacks can
#' call them without reaching into webpack internals. The same names are
#' available as on the JS side of React Router itself.
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
#' \strong{Error helpers}
#' \itemize{
#'   \item \code{isRouteErrorResponse(error)} -- type guard intended for use
#'     inside an \code{errorElement} alongside \code{\link{useRouteError}};
#'     returns \code{true} when the error came from a thrown
#'     \code{Response} (e.g. \code{throw new Response(..., { status: 404 })}).
#' }
#'
#' These are the JavaScript implementations from \code{react-router-dom}, so
#' behavior is exactly faithful to upstream -- unlike the pure-R reimplementations
#' \code{\link{generatePath}} and \code{\link{matchPath}}.
#'
#' @examples
#' \dontrun{
#' # Conditional redirect inside a custom loader.
#' Route(
#'   path = "/admin",
#'   loader = JS("async () => {
#'     const ok = await checkAuth();
#'     if (!ok) return window.reactRouterHelpers.redirect('/login');
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
#'     render = JS("e => window.reactRouterHelpers.isRouteErrorResponse(e)
#'                   ? <p>HTTP {e.status}</p>
#'                   : <p>Unknown error</p>")
#'   ),
#'   element = useLoaderData(tags$pre())
#' )
#' }
#'
#' @name reactRouterHelpers
#' @keywords internal
NULL

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
    stop(sprintf(
      "%s(): `to` must be a single, non-NA character string.", fn
    ), call. = FALSE)
  }
  if (grepl("^\\s*(javascript|data|vbscript):", to, ignore.case = TRUE)) {
    stop(sprintf(
      "%s(): refusing unsafe URL scheme in `to` = %s. ",
      fn, deparse(to)
    ), call. = FALSE)
  }
  # Protocol-relative URLs (//host/...) inherit the page's scheme and send
  # the user off-origin. Safe by default: reject. Callers wanting a
  # cross-origin absolute URL can spell out the full https:// form.
  if (grepl("^\\s*//", to)) {
    stop(sprintf(
      "%s(): refusing protocol-relative URL in `to` = %s. ",
      fn, deparse(to)
    ), "Use a full https:// URL if you really want a cross-origin redirect.",
    call. = FALSE)
  }
}

#' redirect (loader/action helper)
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.redirect.html}
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
#' For conditional redirects inside a custom loader/action, use the global
#' \code{window.reactRouterHelpers.redirect(to)} from your own \code{JS()}
#' string, e.g.
#' \preformatted{
#'   loader = JS(
#'     "async () => { if (!authed()) return window.reactRouterHelpers.redirect('/login'); ... }"
#'   )
#' }
#'
#' The \code{data}, \code{replace}, and \code{redirectDocument} helpers are
#' exposed on the same global (\code{window.reactRouterHelpers.data},
#' \code{...replace}, \code{...redirectDocument}).
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
    '() => window.reactRouterHelpers.redirect(%s)',
    jsLiteral(to)
  ))
}

#' replaceResponse (loader/action helper)
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.replace.html}
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
#' \code{window.reactRouterHelpers.replace(to)} from your own \code{JS()}
#' string.
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
    '() => window.reactRouterHelpers.replace(%s)',
    jsLiteral(to)
  ))
}

#' redirectDocument (loader/action helper)
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.redirectDocument.html}
#'
#' Returns a \code{\link{JS}} loader function that performs a \emph{document}
#' redirect to \code{to} -- a full page reload, as opposed to the client-side
#' navigation that \code{\link{redirect}} performs. Use when navigating to a
#' URL outside the router's control (e.g. a server-rendered page) so the
#' browser fully unloads the SPA.
#'
#' For conditional document redirects inside a custom loader/action, call
#' \code{window.reactRouterHelpers.redirectDocument(to)} from your own
#' \code{JS()} string.
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
    '() => window.reactRouterHelpers.redirectDocument(%s)',
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
#' \code{window.reactRouterHelpers.data(value, init)} directly in your
#' \code{JS()} string, e.g.
#' \preformatted{
#'   loader = JS("async () => {
#'     const rows = await fetchRows();
#'     return window.reactRouterHelpers.data(
#'       \{ rows \}, \{ status: 200 \}
#'     );
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
  valueJS <- serialize(value)
  initStr <- if (!is.null(init)) paste0(", ", serialize(init)) else ""
  shiny.react::JS(sprintf(
    "() => window.reactRouterHelpers.data(%s%s)",
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
#' For convenience, the same function is also reachable inside any user-authored
#' \code{\link{JS}} string as \code{window.reactRouterHelpers.isRouteErrorResponse}.
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
  shiny.react::JS("window.reactRouterHelpers.isRouteErrorResponse")
}

#' generatePath
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.generatePath.html}
#'
#' Builds a concrete pathname by substituting dynamic \code{:param} segments
#' (and the splat \code{*}) in \code{path} with values from \code{params}.
#' Mirrors React Router's helper but is implemented in R so the returned
#' string can be passed directly to \code{\link{Link}}, \code{\link{NavLink}},
#' or any other component's \code{to} prop.
#'
#' Optional segments suffixed with \code{?} are dropped when their value is
#' missing (\code{NULL} or \code{""}); required segments raise an error.
#' Values are URL-encoded with \code{utils::URLencode(reserved = TRUE)} except
#' for the splat \code{*}, whose slashes are preserved.
#'
#' \strong{Note:} this is a pure-R reimplementation of React Router's helper
#' (which itself uses the \code{path-to-regexp} library on the JS side). It
#' covers the common pattern syntax (\code{:param}, \code{:param?}, \code{*})
#' but may diverge in edge cases such as escaping of regex metacharacters
#' inside literal segments or non-trailing splats. For loader/action JS code
#' that must stay strictly faithful to the JS implementation, call
#' \code{window.reactRouterHelpers.generatePath(path, params)} from inside
#' your \code{\link{JS}} string.
#'
#' @param path Character. A path pattern, e.g. \code{"/users/:id"} or
#'   \code{"/files/*"}.
#' @param params Named list (or \code{NULL}) of values for the dynamic
#'   segments. The splat is named \code{"*"}.
#' @return Character scalar, the resolved pathname.
#'
#' @examples
#' generatePath("/users/:id", list(id = 42))
#' generatePath("/users/:id/posts/:postId", list(id = 1, postId = "abc"))
#' generatePath("/files/*", list(`*` = "a/b/c.txt"))
#' generatePath("/posts/:slug?", list())  # optional segment dropped
#'
#' @rdname generatePath
#' @export
generatePath <- function(path, params = list()) {
  if (!is.character(path) || length(path) != 1 || is.na(path)) {
    stop("generatePath(): `path` must be a single, non-NA character string.", call. = FALSE)
  }
  if (is.null(params)) params <- list()
  if (!is.list(params)) {
    stop("generatePath(): `params` must be a named list.", call. = FALSE)
  }

  encodeSegment <- function(v) utils::URLencode(as.character(v), reserved = TRUE)

  # Splat (`*`) — preserves slashes inside the value, unlike :params.
  # `URLencode(reserved = FALSE)` keeps `/` (correct for a splat) but also
  # leaves `?` and `#` raw, which would be mis-parsed downstream as the
  # query/fragment delimiter. Percent-encode them explicitly.
  if (grepl("\\*", path)) {
    splat <- params[["*"]]
    if (is.null(splat)) splat <- ""
    encoded <- utils::URLencode(as.character(splat), reserved = FALSE)
    encoded <- gsub("?", "%3F", encoded, fixed = TRUE)
    encoded <- gsub("#", "%23", encoded, fixed = TRUE)
    path <- gsub("\\*", encoded, path, fixed = FALSE)
  }

  # Iterate over :param[?] segments. We re-scan after each replacement so
  # patterns that share a prefix (e.g. :id and :idType) don't collide.
  pattern <- ":([A-Za-z_][A-Za-z0-9_]*)(\\??)"
  repeat {
    m <- regmatches(path, regexpr(pattern, path))
    if (length(m) == 0) break
    name <- sub(pattern, "\\1", m)
    optional <- endsWith(m, "?")
    val <- params[[name]]
    if (is.null(val) || identical(val, "")) {
      if (!optional) {
        stop(sprintf(
          "generatePath(): missing value for required segment ':%s' in path '%s'.",
          name, path
        ), call. = FALSE)
      }
      replacement <- ""
    } else {
      replacement <- encodeSegment(val)
    }
    path <- sub(pattern, replacement, path)
  }

  # Collapse `//` introduced by dropped optional segments, but keep a leading
  # slash and any protocol-style `://` intact.
  path <- gsub("([^:])//+", "\\1/", path)
  # Trim trailing slash unless the whole path is "/".
  if (nchar(path) > 1) path <- sub("/+$", "", path)
  path
}

#' matchPath
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.matchPath.html}
#'
#' Tests whether \code{pathname} matches \code{pattern} and, if it does,
#' returns a list with the captured \code{params}, the matched
#' \code{pathname}, and a \code{pathnameBase}. Returns \code{NULL} on no
#' match. Implemented in pure R so it can be used outside a browser context
#' (e.g. to drive Shiny logic from a known URL).
#'
#' Supported pattern syntax: \code{:param}, splat \code{*}, optional segments
#' \code{:param?}, and an optional \code{end = FALSE} flag for prefix
#' matching.
#'
#' \strong{Note:} this is a pure-R reimplementation of React Router's helper
#' and may diverge in edge cases (regex metacharacter escaping in literal
#' segments, non-trailing splats). For strict parity with the JS
#' implementation inside a loader/action, call
#' \code{window.reactRouterHelpers.matchPath(pattern, pathname)} from your
#' \code{\link{JS}} string.
#'
#' @param pattern Either a character path pattern (e.g. \code{"/users/:id"})
#'   or a list with elements \code{path} and (optional) \code{end}, \code{caseSensitive}.
#' @param pathname Character. The pathname to test.
#' @return A list with \code{params}, \code{pathname}, \code{pathnameBase},
#'   and \code{pattern}, or \code{NULL} if no match.
#'
#' @examples
#' matchPath("/users/:id", "/users/42")
#' matchPath("/users/:id", "/about")  # NULL
#' matchPath(list(path = "/users", end = FALSE), "/users/42/edit")
#'
#' @rdname matchPath
#' @export
matchPath <- function(pattern, pathname) {
  if (is.character(pattern)) {
    spec <- list(path = pattern, end = TRUE, caseSensitive = FALSE)
  } else if (is.list(pattern) && !is.null(pattern$path)) {
    spec <- list(
      path = pattern$path,
      end = if (is.null(pattern$end)) TRUE else isTRUE(pattern$end),
      caseSensitive = isTRUE(pattern$caseSensitive)
    )
  } else {
    stop("matchPath(): `pattern` must be a string or a list with a `path` element.", call. = FALSE)
  }
  if (!is.character(pathname) || length(pathname) != 1 || is.na(pathname)) {
    stop("matchPath(): `pathname` must be a single, non-NA character string.", call. = FALSE)
  }

  # Parse `:param[?]` and `*` placeholders into a regex with named groups.
  # Strategy: substitute placeholders to NUL-delimited sentinels first,
  # then escape regex specials (including `?` — see issue #N), then
  # substitute the sentinels for the actual regex fragments. Doing it in
  # this order means a literal `?` or `*` in a path segment is treated as
  # a literal character rather than as a regex meta.
  paramNames <- character()
  hasSplat <- FALSE
  rx <- spec$path
  OPT_TOKEN <- "\001OPT\001"
  REQ_TOKEN <- "\001REQ\001"
  SPLAT_TOKEN <- "\001SPLAT\001"

  # :param? -> optional sentinel.
  repeat {
    m <- regmatches(rx, regexpr("/:([A-Za-z_][A-Za-z0-9_]*)\\?", rx))
    if (length(m) == 0) break
    name <- sub("/:([A-Za-z_][A-Za-z0-9_]*)\\?", "\\1", m)
    paramNames <- c(paramNames, name)
    rx <- sub("/:([A-Za-z_][A-Za-z0-9_]*)\\?", OPT_TOKEN, rx)
  }
  # :param -> required sentinel.
  repeat {
    m <- regmatches(rx, regexpr(":([A-Za-z_][A-Za-z0-9_]*)", rx))
    if (length(m) == 0) break
    name <- sub(":([A-Za-z_][A-Za-z0-9_]*)", "\\1", m)
    paramNames <- c(paramNames, name)
    rx <- sub(":([A-Za-z_][A-Za-z0-9_]*)", REQ_TOKEN, rx)
  }
  # `*` splat -> sentinel.
  if (grepl("\\*", rx)) {
    hasSplat <- TRUE
    rx <- sub("\\*", SPLAT_TOKEN, rx)
  }
  # Now escape regex specials in the remaining literal text.
  rx <- gsub("([.+?(){}\\[\\]\\\\^$|])", "\\\\\\1", rx, perl = TRUE)
  # Substitute sentinels for their regex fragments.
  rx <- gsub(OPT_TOKEN, "(?:/([^/]+))?", rx, fixed = TRUE)
  rx <- gsub(REQ_TOKEN, "([^/]+)", rx, fixed = TRUE)
  rx <- gsub(SPLAT_TOKEN, "(.*)", rx, fixed = TRUE)

  rx <- if (spec$end) paste0("^", rx, "/?$") else paste0("^", rx, "(?:/|$)")
  m <- regexec(rx, pathname, perl = TRUE, ignore.case = !spec$caseSensitive)
  hits <- regmatches(pathname, m)[[1]]
  if (length(hits) == 0) return(NULL)

  params <- list()
  if (length(paramNames) > 0) {
    vals <- hits[seq_len(length(paramNames)) + 1]
    vals <- ifelse(vals == "", NA_character_, vals)
    names(vals) <- paramNames
    params <- as.list(vals)
  }
  if (hasSplat) {
    params[["*"]] <- hits[length(hits)]
  }

  matchedPath <- hits[1]
  pathnameBase <- if (hasSplat) {
    sub(paste0("/?", utils::URLencode(params[["*"]] %||% "", reserved = TRUE), "$"), "", matchedPath)
  } else {
    matchedPath
  }

  list(
    params = params,
    pathname = matchedPath,
    pathnameBase = if (nzchar(pathnameBase)) pathnameBase else "/",
    pattern = spec
  )
}

# Internal: tiny null-coalescing helper (used only by matchPath).
`%||%` <- function(a, b) if (is.null(a)) b else a
