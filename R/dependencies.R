# Internal: 16-char random alphanumeric string used as a React key on the
# Keyed wrapper of Route(element=). React keys only need to be unique among
# siblings, not RFC 4122 UUIDs — this avoids a dependency on the `uuid` pkg.
# The user's RNG state is preserved so reproducible tests aren't disturbed.
randomKey <- function() {
  if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
    old <- get(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
    on.exit(assign(".Random.seed", old, envir = .GlobalEnv))
  } else {
    on.exit(suppressWarnings(rm(".Random.seed", envir = .GlobalEnv)))
  }
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
    version = getNamespaceVersion("reactRouter"),
    package = "reactRouter",
    src = c(file = "reactRouter"),
    script = "react-router-dom.js"
  )
}
