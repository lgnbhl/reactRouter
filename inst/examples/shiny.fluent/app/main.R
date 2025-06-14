box::use(
  app / view / home,
  app / view / menu,
  app / view / details,
  app / view / benchmark,
  app / view / rank
)

#' @export
ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny.fluent::fluentPage(
      reactRouter::HashRouter(
        reactRouter::Routes(
          reactRouter::Route(
            path = "/",
            element = home$ui(ns("home"))
          ),
          reactRouter::Route(
            path = "/:projectId/*",
            element = menu$ui(ns("menu")),
            children = list(
              reactRouter::Route(
                path = "details",
                element = details$ui(ns("details"))
              ),
              reactRouter::Route(
                path = "benchmark",
                element = benchmark$ui(ns("benchmark"))
              ),
              reactRouter::Route(
                path = "rank",
                element = rank$ui(ns("rank"))
              )
            )
          ),
          reactRouter::Route(path = "*", element = "Custom error 404")
        )
      )
    )
  )
}

#' @export
server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {
    hero_selected <- home$server("home")

    shiny::observe({
      shiny::req(hero_selected())

      print(paste0("hero_id selected: ", hero_selected()))
    })

    menu$server("menu", hero_selected = hero_selected)
    details$server("details", hero_selected = hero_selected)
    benchmark$server("benchmark", hero_selected = hero_selected)
    rank$server("rank", hero_selected = hero_selected)
  })
}
