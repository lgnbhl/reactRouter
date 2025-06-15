box::use(
    app / view / header,
    app / logic / data[hero_stats]
)

#' @export
ui <- function(id) {
    ns <- shiny::NS(id)
    shiny::tagList(
        header$ui(ns("header")),
        shiny.fluent::Stack(
            horizontal = TRUE,
            horizontalAlign = "center",
            styles = list(
                root = list(width = "100%")
            ),
            shiny.fluent::Stack(
                styles = list(root = list(width = "50%")),
                echarts4r::echarts4rOutput(ns("rank_plot"))
            ),
            shiny.fluent::Stack(
                styles = list(root = list(width = "50%")),
                echarts4r::echarts4rOutput(ns("rank_prop_plot"))
            )
        )
    )
}

#' @export
server <- function(id, hero_selected) {
    shiny::moduleServer(id, function(input, output, session) {
        ns <- session$ns

        hero_details <- shiny::reactive({
            shiny::req(hero_selected())

            x <- purrr::keep(
                hero_stats,
                ~ .x$id == as.integer(hero_selected())
            ) |>
                purrr::pluck(1)

            tibble::tibble(
                win = unlist(x[["pub_win_trend"]]),
                pick = unlist(x[["pub_pick_trend"]]),
                rank = c(
                    "Herald",
                    "Guardian",
                    "Crusader",
                    "Archon",
                    "Legend",
                    "Ancient",
                    "Divine"
                )
            )
        })

        output$rank_prop_plot <- echarts4r::renderEcharts4r({
            shiny::req(hero_details())

            hero <- hero_details()

            hero |>
                dplyr::mutate(win_prop = win / pick) |>
                echarts4r::e_chart(rank) |>
                echarts4r::e_bar(win_prop, legend = FALSE)
        })

        output$rank_plot <- echarts4r::renderEcharts4r({
            shiny::req(hero_details())

            hero <- hero_details()

            hero |>
                tidyr::gather(variable, value, -rank) |>
                dplyr::group_by(variable) |>
                echarts4r::e_chart(rank) |>
                echarts4r::e_area(value) |>
                echarts4r::e_tooltip(trigger = "axis")
        })

        header$server("header", hero_selected = hero_selected)
    })
}
