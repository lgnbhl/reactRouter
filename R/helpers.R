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

#' replace (loader/action helper)
#'
#' \url{https://api.reactrouter.com/v7/functions/react-router.replace.html}
#'
#' Returns a \code{\link{JS}} loader function that performs a \emph{replace}
#' navigation to \code{to} -- same as \code{\link{redirect}}, but the new
#' entry replaces the current one in the history stack instead of pushing
#' a new one. Use for "alias" routes where the original URL should not
#' remain in the user's back-history.
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
#' Route(path = "/legacy", loader = replace("/new"), element = NULL)
#' }
#'
#' @rdname replace
#' @export
replace <- function(to) {
  if (!is.character(to) || length(to) != 1 || is.na(to)) {
    stop(
      "replace(): `to` must be a single, non-NA character string.",
      call. = FALSE
    )
  }
  escaped <- gsub("\\\\", "\\\\\\\\", to)
  escaped <- gsub('"', '\\\\"', escaped)
  shiny.react::JS(sprintf(
    '() => window.reactRouterHelpers.replace("%s")',
    escaped
  ))
}

#' data (loader/action helper)
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
#'   loader = data(
#'     list(name = "Ada", role = "Engineer"),
#'     init = list(status = 200)
#'   ),
#'   element = useLoaderData(tags$pre())
#' )
#' }
#'
#' @name data-helper
#' @export
data <- function(value = NULL, init = NULL) {
  serialize <- function(x) {
    if (inherits(x, "JS_EVAL")) {
      return(as.character(x))
    }
    if (!requireNamespace("jsonlite", quietly = TRUE)) {
      stop(
        "data(): the 'jsonlite' package is required to serialize R objects. ",
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
