# useLoaderData example — MUI Data Grid + Autocomplete filter powered by JS loaders
# Demonstrates: useLoaderData wrapping muiDataGrid::DataGrid() and muiMaterial::Autocomplete()
# Requires: library(muiDataGrid), library(muiMaterial)

library(reactRouter)
library(muiDataGrid) # https://github.com/lgnbhl/muiDataGrid
library(muiMaterial) # https://github.com/lgnbhl/muiMaterial
library(htmltools)

# -- JS loader: fetches Star Wars characters from SWAPI, filters by ?name= param ----
loader_people <- JS(
  "
  async ({ request }) => {
    const filter = new URL(request.url).searchParams.getAll('name');
    const data = await fetch('https://swapi.info/api/people').then(r => r.json());
    return {
      names: data.map(p => p.name).sort(),
      people: filter.length ? data.filter(p => filter.includes(p.name)) : data
    };
  }
"
)

# -- UI --------------------------------------------------------------------
ui <- RouterProvider(
  router = createMemoryRouter(
    Route(
      path = "/",
      loader = loader_people,
      element = div(
        h2("Star Wars Characters"),
        p(
          "Select characters to filter the table, or clear the selection to show all."
        ),
        useLoaderData(
          into = muiMaterial::Autocomplete(
            onChange = JS(
              "(event, value) => { window.location.hash = value.length ? '/?' + value.map(v => 'name=' + encodeURIComponent(v)).join('&') : '/'; }"
            ),
            renderInput = JS(
              "(params) => React.createElement(window.jsmodule['@mui/material'].TextField, {...params, label: 'Name'})"
            ),
            multiple = TRUE,
            sx = list(width = 300, marginBottom = 2)
          ),
          as = "options",
          selector = "names"
        ),
        useLoaderData(
          into = muiDataGrid::DataGrid(
            columns = list(
              list(field = 'name', headerName = 'Name', flex = 1),
              list(field = 'height', headerName = 'Height', width = 100),
              list(field = 'mass', headerName = 'Mass', width = 100),
              list(field = 'gender', headerName = 'Gender', width = 120),
              list(field = 'birth_year', headerName = 'Birth Year', width = 120)
            ),
            getRowId = JS("function(row) { return(row.name) }"),
            initialState = list(
              pagination = list(paginationModel = list(pageSize = 5))
            ),
            showToolbar = TRUE
          ),
          as = "rows",
          selector = "people"
        )
      )
    )
  )
)

# htmltools::save_html(ui, "index.html")
browsable(ui)
