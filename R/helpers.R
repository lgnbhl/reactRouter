# Internal: escape an R string so it can be safely embedded inside a
# double-quoted JavaScript string literal. Backslashes first, then quotes.
jsString <- function(x) {
  x <- gsub("\\\\", "\\\\\\\\", x)
  gsub('"', '\\\\"', x)
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
  if (!is.character(to) || length(to) != 1 || is.na(to)) {
    stop(
      "redirect(): `to` must be a single, non-NA character string.",
      call. = FALSE
    )
  }
  shiny.react::JS(sprintf(
    '() => window.reactRouterHelpers.redirect("%s")',
    jsString(to)
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
  if (!is.character(to) || length(to) != 1 || is.na(to)) {
    stop(
      "replaceResponse(): `to` must be a single, non-NA character string.",
      call. = FALSE
    )
  }
  shiny.react::JS(sprintf(
    '() => window.reactRouterHelpers.replace("%s")',
    jsString(to)
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
  if (!is.character(to) || length(to) != 1 || is.na(to)) {
    stop(
      "redirectDocument(): `to` must be a single, non-NA character string.",
      call. = FALSE
    )
  }
  shiny.react::JS(sprintf(
    '() => window.reactRouterHelpers.redirectDocument("%s")',
    jsString(to)
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
dataResponse <- function(value = NULL, init = NULL) {
  serialize <- function(x) {
    if (inherits(x, "JS_EVAL")) {
      return(as.character(x))
    }
    if (!requireNamespace("jsonlite", quietly = TRUE)) {
      stop(
        "dataResponse(): the 'jsonlite' package is required to serialize R objects. ",
        "Install it, or pass `value`/`init` as JS() expressions.",
        call. = FALSE
      )
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
  if (grepl("\\*", path)) {
    splat <- params[["*"]]
    if (is.null(splat)) splat <- ""
    path <- gsub("\\*", utils::URLencode(as.character(splat), reserved = FALSE), path, fixed = FALSE)
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
  paramNames <- character()
  hasSplat <- FALSE
  rx <- spec$path
  # Escape regex specials except ":", "*", and "?" which we transform.
  rx <- gsub("([.+(){}\\[\\]\\\\^$|])", "\\\\\\1", rx, perl = TRUE)

  # :param? -> optional capturing group, including the leading slash.
  repeat {
    m <- regmatches(rx, regexpr("/:([A-Za-z_][A-Za-z0-9_]*)\\?", rx))
    if (length(m) == 0) break
    name <- sub("/:([A-Za-z_][A-Za-z0-9_]*)\\?", "\\1", m)
    paramNames <- c(paramNames, name)
    rx <- sub("/:([A-Za-z_][A-Za-z0-9_]*)\\?", "(?:/([^/]+))?", rx)
  }
  # :param  -> required capturing group
  repeat {
    m <- regmatches(rx, regexpr(":([A-Za-z_][A-Za-z0-9_]*)", rx))
    if (length(m) == 0) break
    name <- sub(":([A-Za-z_][A-Za-z0-9_]*)", "\\1", m)
    paramNames <- c(paramNames, name)
    rx <- sub(":([A-Za-z_][A-Za-z0-9_]*)", "([^/]+)", rx)
  }
  # `*` splat -> capture the rest (including slashes).
  if (grepl("\\*", rx)) {
    hasSplat <- TRUE
    rx <- sub("\\*", "(.*)", rx)
  }

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
