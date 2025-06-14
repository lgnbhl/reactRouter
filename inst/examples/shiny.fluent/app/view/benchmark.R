box::use(
    app / view / header
)

#' @export
ui <- function(id) {
    ns <- shiny::NS(id)

    shiny::tagList(
        header$ui(ns("header")),
        shiny::uiOutput(ns("benchmark_ui"))
    )
}

#' @export
server <- function(id, hero_selected) {
    shiny::moduleServer(id, function(input, output, session) {
        ns <- session$ns

        benchmark_data <- shiny::reactive({
            shiny::req(hero_selected())

            data <- httr::GET(paste0(
                "https://api.opendota.com/api/benchmarks?hero_id=",
                hero_selected()
            ))
            data <- httr::content(data)

            data$result |>
                purrr::map(function(.x) {
                    purrr::map(.x, as.data.frame) |>
                        dplyr::bind_rows()
                }) |>
                purrr::imap_dfr(~ dplyr::mutate(.x, metric = .y))
        })

        output$benchmark_ui <- shiny::renderUI({
            shiny::req(benchmark_data())

            benchmark_data <- benchmark_data()

            purrr::walk2(
                unique(benchmark_data$metric),  
                seq_along(unique(benchmark_data$metric)),
                function(.x, i) {
                    output[[paste0(
                        "chart_",
                        .x
                    )]] <- echarts4r::renderEcharts4r({
                        plot <- benchmark_data |>
                            dplyr::filter(metric == .x) |>
                            echarts4r::e_charts(percentile) |>
                            echarts4r::e_area(value, legend = FALSE) |>
                            echarts4r::e_tooltip(trigger = "axis") |>
                            echarts4r::e_group("charts")

                        # Call e_connect_group only on the last chart
                        if (i == length(unique(benchmark_data$metric))) {
                            plot <- plot |>
                                echarts4r::e_connect_group("charts")
                        }

                        plot
                    })
                }
            )

            shiny::div(
                style = "display: grid; grid-template-columns: repeat(auto-fill, minmax(240px, 1fr)); gap: 32px; max-width: 1080px; margin: 0 auto; padding: 40px 20px;",
                shiny::tagList(
                    purrr::map(unique(benchmark_data$metric), function(.x) {
                        shiny::div(
                            shiny::h4(.x),
                            echarts4r::echarts4rOutput(
                                outputId = ns(paste0("chart_", .x)),
                                height = "300px"
                            )
                        )
                    })
                )
            )
        })

        header$server("header", hero_selected = hero_selected)
    })
}
