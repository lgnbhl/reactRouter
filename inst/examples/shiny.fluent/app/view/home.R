box::use(
    app / logic / data[hero_stats],
    app / logic / utils
)

#' @export
ui <- function(id) {
    ns <- shiny::NS(id)

    shiny::tagList(
        shiny.fluent::Stack(
            horizontal = FALSE,
            horizontalAlign = "center",
            shiny.fluent::Text(
                "reactRouter + Rhino + shiny.fluent + opendota",
                variant = "xLarge"
            ),
            shiny.fluent::Text(
                "This is a simple example of a Shiny app using reactRouter, Rhino, ",
                "and shiny.fluent to display a list of heroes from the OpenDota API exploring dynamic routing."
            ),
            shiny.fluent::Text(
                "Click on a hero to view their details. ",
                "The hero's ID will be included in the URL, allowing for dynamic routing, e.g, /#/{hero_id}/details."
            )
        ),
        shiny.fluent::Stack(
            horizontal = TRUE,
            horizontalAlign = "center",
            styles = list(root = list(marginTop = 32)), # Add distance from the element on top
            shiny.fluent::SearchBox.shinyInput(
                ns("search"),
                placeholder = "Search for a Dota 2 hero...",
                underlined = TRUE,
                iconProps = list(iconName = "Search"),
                styles = list(root = list(width = 300))
            )
        ),
        shiny::uiOutput(ns("hero_list"))
    )
}

#' @export
server <- function(id) {
    shiny::moduleServer(id, function(input, output, session) {
        ns <- session$ns

        hero_stats_filter <- shiny::reactive({
            if (nchar(input$search) > 2) {
                heros_name <- unlist(purrr::map(
                    hero_stats,
                    ~ .x[["localized_name"]]
                ))

                # Find the hero name with the highest match to input$search using stringdist
                distances <- stringdist::stringdist(
                    tolower(input$search),
                    tolower(heros_name),
                    method = "jw"
                )
                if (any(distances == 0)) {
                    return(hero_stats[which(distances == 0)])
                }

                index <- which(distances >= 0 & distances <= 0.4)
                if (length(index) > 0) {
                    return(hero_stats[index])
                } else {
                    return(NULL)
                }
            } else {
                return(hero_stats)
            }
        })

        output$hero_list <- shiny::renderUI({
            if (is.null(hero_stats_filter())) {
                shiny::div(
                    style = "
                        position: absolute;
                        top: 50%;
                        left: 50%;
                        transform: translate(-50%, -50%);
                        font-size: 1.2em;
                        text-align: center;
                    ",
                    "No heroes found matching your search criteria."
                )
            } else {
                shiny::req(hero_stats_filter())

                hero_list <- purrr::map(hero_stats_filter(), function(.x) {
                    shiny::div(
                        shiny.fluent::DocumentCard(
                            styles = list(
                                root = list(
                                    "max-width" = "100%",
                                    width = "250px"
                                ) # Card is 250px wide
                            ),
                            onClickHref = paste0("#/", .x$id, "/details"),
                            shiny.fluent::DocumentCardPreview(
                                previewImages = list(
                                    list(
                                        name = "",
                                        previewImageSrc = paste0(
                                            "https://cdn.cloudflare.steamstatic.com",
                                            .x$img
                                        ),
                                        width = 250, # Match the card width
                                        height = 140, # Adjust proportionally (e.g., 16:9 = 250 x 140)
                                        imageFit = "cover"
                                    )
                                )
                            ),
                            shiny.fluent::Stack(
                                horizontal = FALSE,
                                horizontalAlign = "center", # Center icons horizontally
                                tokens = list(childrenGap = 5),
                                styles = list(root = list(marginBottom = 10)), # Space below the Stack
                                children = list(
                                    shiny::span(.x$localized_name),
                                    shiny::span(
                                        toupper(.x$primary_attr),
                                        style = paste0(
                                            "color: ",
                                            utils$primary_attr_color(
                                                .x$primary_attr
                                            ),
                                            "; font-weight: bold;"
                                        )
                                    )
                                )
                            )
                        )
                    )
                })

                shiny::div(
                    style = "display: grid; grid-template-columns: repeat(auto-fill, minmax(240px, 1fr)); gap: 32px; max-width: 1080px; margin: 0 auto; padding: 40px 20px;",
                    shiny::tagList(hero_list)
                )
            }
        })

        return(shiny::reactive({
            current_route <- sub("#/", "", session$clientData$url_hash)
            # print(current_route)
            return(stringr::str_extract(current_route, "\\d+"))
        }))
    })
}
