# Example showing useLoaderData() which exposes useLoaderData()
# Demonstrates:
#   - Accessing individual keys with `selector`
#   - Combining useLoaderData with useParams for dynamic loaders
#   - Using useRouteLoaderData to access a parent route's loader from a child

library(reactRouter)
library(htmltools)
library(dplyr)

# --- Data defined in R -----------------------------------------------------------

# Serialize for use in JS loaders
# Array of objects
people_json <- dplyr::starwars |>
  mutate(id = dplyr::row_number()) |>
  jsonlite::toJSON(dataframe = "rows", auto_unbox = TRUE)

# --- App -------------------------------------------------------------------------

ui <- RouterProvider(
  Route(
    path = "/",
    element = div(
      tags$h2("Loader Demo"),
      tags$nav(tags$ul(
        tags$li(NavLink(to = "/", "Home")),
        tags$li(NavLink(to = "/people", "People List")),
        tags$li(NavLink(to = "/people/1", "Person 1")),
        tags$li(NavLink(to = "/people/2", "Person 2")),
        tags$li(NavLink(to = "/people/3", "Person 3"))
      )),
      tags$hr(),
      Outlet()
    ),
    Route(
      index = TRUE,
      element = tags$p("Welcome! Select a page from the nav above.")
    ),
    Route(
      path = "people",
      element = div(
        muiDataGrid::DataGrid(
          rows = dplyr::starwars,
          initialState = list(
            pagination = list(paginationModel = list(pageSize = 5))
          ),
          showToolbar = TRUE
        )
      )
    ),
    Route(
      path = "people/:id",
      loader = JS(
        sprintf(
          "({ params }) => {
            const starwars_db = %s;
            
            // Think of .find() as a subset() that returns only the first match
            const person = starwars_db.find(row => row.id == params.id);
            
            // Error handling (similar to an if/stop statement in R)
            if (!person) {
              throw new Response('Character not found', { status: 404 });
            }
            
            return person;
            }",
          people_json
        )
      ),
      element = div(
        useLoaderData(tags$h3(), selector = "name"),
        tags$table(
          style = "border-collapse: collapse;",
          tags$tr(
            tags$th(style = "text-align: left; padding: 4px 12px;", "Gender"),
            tags$td(
              style = "padding: 4px 12px;",
              useLoaderData(tags$span(), selector = "gender")
            )
          ),
          tags$tr(
            tags$th(style = "text-align: left; padding: 4px 12px;", "Species"),
            tags$td(
              style = "padding: 4px 12px;",
              useLoaderData(tags$span(), selector = "species")
            )
          )
        )
      ),
      errorElement = div(
        tags$h3(style = "color: red;", "Person not found"),
        tags$p(NavLink(to = "/people", "Back to people list"))
      )
    )
  )
)

# htmltools::save_html(ui, "index.html")
htmltools::browsable(ui)
