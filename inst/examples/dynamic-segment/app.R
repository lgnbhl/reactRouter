# reactRouter with route parameters

library(shiny)
library(reactRouter)
library(bslib)
library(dplyr)
library(tidyr)
library(stringr)

# create list of nested datasets by id
data_nested_by_id <- dplyr::starwars |>
  tidyr::unnest_longer(col = films) |>
  dplyr::nest_by(films) |>
  rename(title = films) |>
  mutate(id = case_match(
    title,
    "A New Hope" ~ 1,
    "The Empire Strikes Back" ~ 2,
    "Return of the Jedi" ~ 3,
    "The Phantom Menace" ~ 4,
    "Attack of the Clones" ~ 5,
    "Revenge of the Sith" ~ 6,
    "The Force Awakens" ~ 7)
  ) |>
  arrange(id)

# image URLs for cards
img_by_id <- tibble::tribble(
  ~id, ~img,
  1,   "https://upload.wikimedia.org/wikipedia/en/8/87/StarWarsMoviePoster1977.jpg",
  2,   "https://upload.wikimedia.org/wikipedia/en/3/3f/The_Empire_Strikes_Back_%281980_film%29.jpg",
  3,   "https://upload.wikimedia.org/wikipedia/en/b/b2/ReturnOfTheJediPoster1983.jpg",
  4,   "https://upload.wikimedia.org/wikipedia/en/4/40/Star_Wars_Phantom_Menace_poster.jpg",
  5,   "https://upload.wikimedia.org/wikipedia/en/3/32/Star_Wars_-_Episode_II_Attack_of_the_Clones_%28movie_poster%29.jpg",
  6,   "https://upload.wikimedia.org/wikipedia/en/9/93/Star_Wars_Episode_III_Revenge_of_the_Sith_poster.jpg",
  7,   "https://upload.wikimedia.org/wikipedia/en/a/a2/Star_Wars_The_Force_Awakens_Theatrical_Poster.jpg"
)

create_card <- function(id) {
  a(
    href = paste0("#/project/", id, "/overview"),
    style = "text-decoration: none",
    card(
      card_body(
        class = "p-0",
        card_image(
          img_by_id$img[id]
        )
      ),
      card_footer(
        data_nested_by_id$title[id]
      )
    )
  )
}

cards_home <- purrr::map(
  .x = data_nested_by_id$id, 
  .f = create_card
)

ui <- reactRouter::HashRouter(
  bslib::page_navbar(
    window_title = "reactRouter | dynamic segments",
    title = span(
      reactRouter::Link(
        to = "/", 
        "reactRouter with dynamic segments",
        style = "text-decoration: none; color: black"
      )
    ),
    nav_spacer(),
    nav_item(
      tags$a(
        shiny::icon("code"),
        href = "https://github.com/lgnbhl/reactRouter/tree/main/inst/examples"
      )
    ),
    reactRouter::Routes(
      reactRouter::Route(
        path = "/",
        element = div(
          class = "p-2",
          uiOutput("uiHome")
        )
      ),
      reactRouter::Route(
        path = "project/:id",
        element = bslib::page_navbar(
          nav_item(
            NavLink(
              to = "overview", 
              "Overview"
            )
          ),
          nav_item(
            NavLink(
              to = "analysis", 
              "Analysis"
            )
          ),
          bslib::nav_spacer(),
          nav_item(
            NavLink(
              to = "/", 
              shiny::icon("home")
            )
          ),
          Outlet()
        ),
        children = list(
          reactRouter::Route(
            path = "overview",
            element = uiOutput("uiOverview")
          ),
          reactRouter::Route(
            path = "analysis",
            element = uiOutput("uiAnalysis")
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {
  
  url_hash <- shiny::reactiveVal(value = NA)
  url_hash_cleaned <- shiny::reactiveVal(value = NA)
  
  # update reactive values based on url hash
  shiny::observe({
    current_url_hash <- sub("#/", "", session$clientData$url_hash)
    # print(current_url_hash)
    url_hash(current_url_hash)
    
    # extract numeric id from current url hash
    current_url_hash_cleaned <- as.integer(stringr::str_extract(current_url_hash, "\\d+"))
    # print(current_url_hash_cleaned)
    url_hash_cleaned(current_url_hash_cleaned)
  })
  
  output$uiHome <- shiny::renderUI({
    bslib::layout_column_wrap(
      width = 1/7,
      !!!unname(cards_home)
    )
  })
  
  data <- reactive({
    req(url_hash_cleaned())
    # get nested data
    data_selected <- data_nested_by_id$data[[url_hash_cleaned()]]
    
    species <- data_selected |>
      count(species, sort = TRUE) |>
      na.omit() |>
      pull(species)
    
    oldest <- data_selected |>
      arrange(desc(birth_year)) |>
      head(1)
    
    tallest <- data_selected |>
      arrange(desc(height)) |>
      head(1)
    
    lightest <- data_selected |>
      arrange(mass) |>
      head(1)
    
    tibble(
      indicator = c("Species", "Oldest", "Tallest", "Lightest"),
      value = c(length(species), oldest$birth_year, tallest$height, lightest$height),
      desc = c(paste(species, collapse = ", "), oldest$name, tallest$name, lightest$name)
    )
  })
  
  output$uiOverview <- renderUI({
    layout_column_wrap(
      width = 1/2,
      class = "p-3",
      card(
        card_header("Session and data"),
        tags$p(
          tags$b("Current hash url: "),
          paste0("'", url_hash(), "'")
        ),
        tags$p(
          tags$b("Current cleaned hash url: "),
          paste0("'", url_hash_cleaned(), "'")
        ),
        tags$p(
          tags$b(tags$code("title"), "of the data: "),
          paste0("'", data_nested_by_id$title[url_hash_cleaned()], "'")
        ),
        tags$p(
          tags$b(tags$code("id"), "of the data: "),
          paste0("'", data_nested_by_id$id[url_hash_cleaned()], "'")
        )
      ),
      layout_column_wrap(
        width = 1/2,
        heights_equal = "row",
        value_box(
          title = "Species",
          showcase = shiny::icon("users"),
          value = filter(data(), indicator == "Species")$value,
          shiny::markdown(filter(data(), indicator == "Species")$desc)
        ),
        value_box(
          title = "Oldest",
          showcase = shiny::icon("person-cane"),
          value = filter(data(), indicator == "Oldest")$value,
          shiny::markdown(filter(data(), indicator == "Oldest")$desc)
        ),
        value_box(
          title = "Tallest",
          showcase = shiny::icon("up-long"),
          value = filter(data(), indicator == "Tallest")$value,
          shiny::markdown(filter(data(), indicator == "Tallest")$desc)
        ),
        value_box(
          title = "Lightest",
          showcase = shiny::icon("feather"),
          value = filter(data(), indicator == "Lightest")$value,
          shiny::markdown(filter(data(), indicator == "Lightest")$desc)
        )
      )
    )
  })
  
  output$uiAnalysis <- renderUI({
    layout_column_wrap(
      width = 1/2,
      class = "p-3",
      card(
        card_header("Session and data"),
        tags$p(
          tags$b("Current hash url: "),
          paste0("'", url_hash(), "'")
        ),
        tags$p(
          tags$b("Current cleaned hash url: "),
          paste0("'", url_hash_cleaned(), "'")
        )
      ),
      card(
        card_header("Package documentation"),
        card_body(shiny::markdown("Learn more about **reactRouter** [here](https://felixluginbuhl.com/reactRouter/)."))
      )
    )
  })
  
}

shinyApp(ui, server)
