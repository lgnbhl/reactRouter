box::use(
    app / view / header,
    app / logic / data[hero_stats]
)


#' @export
ui <- function(id) {
    ns <- shiny::NS(id)

    shiny::uiOutput(ns("details_page"))
}

#' @export
server <- function(id, hero_selected) {
    shiny::moduleServer(id, function(input, output, session) {
        ns <- session$ns

        output$details_page <- shiny::renderUI({
            shiny::req(hero_selected())

            hero <- purrr::keep(
                hero_stats,
                ~ .x$id == as.integer(hero_selected())
            ) |>
                purrr::pluck(1)

            shiny.fluent::fluentPage(
                style = "background-color: #1b2838; color: white;",

                header$ui(ns("header")),

                shiny.fluent::Stack(
                    # Stats Sections
                    shiny.fluent::Stack(
                        horizontal = TRUE,
                        horizontalAlign = "space-evenly",
                        tokens = list(childrenGap = 20),
                        maxWidth = "100%",
                        styles = list(root = list(width = "100%")),

                        # Attributes
                        shiny.fluent::Stack(
                            tokens = list(childrenGap = 10),
                            shiny.fluent::Text(
                                variant = "large",
                                "Attributes"
                            ),
                            shiny.fluent::Text(paste(
                                "STR:",
                                hero$base_str,
                                "+",
                                hero$str_gain
                            )),
                            shiny.fluent::Text(paste(
                                "AGI:",
                                hero$base_agi,
                                "+",
                                hero$agi_gain
                            )),
                            shiny.fluent::Text(paste(
                                "INT:",
                                hero$base_int,
                                "+",
                                hero$int_gain
                            ))
                        ),

                        # Combat
                        shiny.fluent::Stack(
                            tokens = list(childrenGap = 10),
                            shiny.fluent::Text(
                                variant = "large",
                                "Combat Stats"
                            ),
                            shiny.fluent::Text(paste(
                                "Base Attack:",
                                hero$base_attack_min,
                                "-",
                                hero$base_attack_max
                            )),
                            shiny.fluent::Text(paste(
                                "Attack Range:",
                                hero$attack_range
                            )),
                            shiny.fluent::Text(paste(
                                "Attack Speed:",
                                round(1 / hero$attack_rate * 100, 2)
                            )),
                            shiny.fluent::Text(paste(
                                "Projectile Speed:",
                                hero$projectile_speed
                            ))
                        ),

                        # Survivability
                        shiny.fluent::Stack(
                            tokens = list(childrenGap = 10),
                            shiny.fluent::Text(
                                variant = "large",
                                "Survivability"
                            ),
                            shiny.fluent::Text(paste(
                                "Health:",
                                hero$base_health
                            )),
                            shiny.fluent::Text(paste(
                                "Health Regen:",
                                hero$base_health_regen
                            )),
                            shiny.fluent::Text(paste(
                                "Mana:",
                                hero$base_mana
                            )),
                            shiny.fluent::Text(paste(
                                "Mana Regen:",
                                hero$base_mana_regen
                            )),
                            shiny.fluent::Text(paste(
                                "Armor:",
                                hero$base_armor
                            )),
                            shiny.fluent::Text(paste(
                                "Magic Resist:",
                                paste0(hero$base_mr, "%")
                            ))
                        )
                    ),

                    shiny.fluent::Separator(),

                    # Misc Info
                    shiny.fluent::Stack(
                        horizontal = TRUE,
                        horizontalAlign = "center",
                        tokens = list(childrenGap = 40),
                        shiny.fluent::Text(paste(
                            "Move Speed:",
                            hero$move_speed
                        )),
                        shiny.fluent::Text(paste(
                            "Day Vision:",
                            hero$day_vision
                        )),
                        shiny.fluent::Text(paste(
                            "Night Vision:",
                            hero$night_vision
                        )),
                        shiny.fluent::Text(paste("Legs:", hero$legs)),
                        shiny.fluent::Text(paste(
                            "CM Enabled:",
                            ifelse(hero$cm_enabled, "Yes", "No")
                        ))
                    )
                )
            )
        })

        header$server("header", hero_selected = hero_selected)
    })
}
