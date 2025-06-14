# fmt: skip
links <- tibble::tribble(
  ~ route, ~ name, ~ icon,
  '','Heroes', 'GridViewSmall',
  'details','Details', 'ProductList',
  'benchmark','Benchmark', 'ProductVariant',
  'rank', 'Rank', 'Medal'
)

#' @export
ui <- function(id) {
    ns <- shiny::NS(id)
    shiny::div(
        class = "wrapper",
        shiny::div(
            class = "grid-container",
            shiny::uiOutput(ns("navbar")),
            shiny::div(class = "main", reactRouter::Outlet())
        )
    )
}

#' @export
server <- function(id, hero_selected) {
    shiny::moduleServer(id, function(input, output, session) {
        ns <- session$ns

        output$navbar <- shiny::renderUI({
            shiny::req(hero_selected())

            navigation <- shiny.fluent::Nav(
                groups = list(
                    list(
                        links = (purrr::map(
                            split(links, seq(nrow(links))),
                            function(.x) {
                                list(
                                    name = .x$name,
                                    url = ifelse(
                                        .x$route == "",
                                        "#/",
                                        paste0(
                                            "#/",
                                            hero_selected(),
                                            "/",
                                            .x$route
                                        )
                                    ),
                                    key = .x$route,
                                    icon = .x$icon
                                )
                            }
                        ) |>
                            unname())
                    )
                ),
                initialSelectedKey = '',
                styles = list(
                    root = list(
                        height = '100%',
                        boxSizing = 'border-box',
                        overflowY = 'auto'
                    )
                )
            )

            shiny::div(class = "sidenav", navigation)
        })
    })
}
