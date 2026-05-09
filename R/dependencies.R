# Internal: 16-char random alphanumeric string used as a React key on the
# div() wrapper of Route(element=). React keys only need to be unique among
# siblings, not RFC 4122 UUIDs — this avoids a dependency on the `uuid` pkg.
randomKey <- function() {
  paste0(sample(c(0:9, letters), 16, replace = TRUE), collapse = "")
}

#' react-router-dom JS dependency
#'
#' @return HTML dependency object.
#'
#' @export
reactRouterDependency <- function() {
  htmltools::htmlDependency(
    name = "reactRouter",
    version = as.character(utils::packageVersion("reactRouter")),
    package = "reactRouter",
    src = c(file = "reactRouter"),
    script = "react-router-dom.js"
  )
}
