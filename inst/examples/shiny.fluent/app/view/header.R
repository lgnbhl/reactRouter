box::use(
    app / logic / data[hero_stats]
)

#' @export
ui <- function(id) {
    ns <- shiny::NS(id)

    shiny::uiOutput(ns("header"))
}

#' @export
server <- function(id, hero_selected) {
    shiny::moduleServer(id, function(input, output, session) {
        ns <- session$ns

        output$header <- shiny::renderUI({
            shiny::req(hero_selected())

            hero <- purrr::keep(
                hero_stats,
                ~ .x$id == as.integer(hero_selected())
            ) |>
                purrr::pluck(1)

            shiny::tagList(
                shiny.fluent::Stack(
                    tokens = list(childrenGap = 20),
                    horizontalAlign = "center",
                    styles = list(
                        root = list(
                            padding = 20,
                            margin = "0 auto"
                        )
                    ),
                    shiny.fluent::Stack(
                        horizontal = TRUE,
                        maxWidth = "100%",
                        styles = list(root = list(width = "100%")),
                        horizontalAlign = "space-evenly",
                        tokens = list(childrenGap = 20),
                        shiny.fluent::Image(
                            src = paste0(
                                "https://cdn.cloudflare.steamstatic.com",
                                hero$img
                            ),
                            width = 256,
                            height = 144
                        ),
                        shiny.fluent::Stack(
                            tokens = list(childrenGap = 8),
                            shiny.fluent::Text(
                                variant = "xxLarge",
                                hero$localized_name
                            ),
                            shiny.fluent::Text(
                                variant = "large",
                                paste(
                                    toupper(hero$attack_type),
                                    "-",
                                    paste(unlist(hero$roles), collapse = ", ")
                                )
                            ),
                            shiny.fluent::Stack(
                                horizontal = TRUE,
                                tokens = list(childrenGap = 8),
                                lapply(hero$roles, function(role) {
                                    shiny.fluent::Text(
                                        role,
                                        styles = list(
                                            root = list(
                                                background = "#e54d2e",
                                                color = "white",
                                                padding = "4px 10px",
                                                borderRadius = 12,
                                                fontSize = 12,
                                                fontWeight = 500
                                            )
                                        )
                                    )
                                })
                            )
                        )
                    ),

                    shiny.fluent::Separator()
                )
            )
        })
    })
}