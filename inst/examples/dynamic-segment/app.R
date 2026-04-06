# Star Wars Explorer — static HTML dashboard powered by SWAPI
# Demonstrates: useLoaderData, useParams, useSearchParams, useNavigation,
#               useRouteError, useLocation, NavLink, Outlet, createHashRouter,
#               createRoutesFromElements, data loaders (fetch from swapi.info),
#               muiCharts (BarChart, Gauge), muiMaterial (AppBar, Card, Grid)

library(reactRouter)
library(muiDataGrid)
library(muiCharts)
library(muiMaterial)
library(htmltools)

# -- Star Wars theme -----------------------------------------------------------
sw_yellow <- "#FFE81F"
sw_bg <- "#0D0D0D"
sw_card <- "#1a1a2e"
sw_text <- "#c7c7c7"

sw_mui_theme <- list(
  palette = list(
    mode = "dark",
    primary = list(main = sw_yellow),
    secondary = list(main = "#4a4a6a"),
    background = list(default = sw_bg, paper = sw_card),
    text = list(primary = sw_text, secondary = "#888")
  ),
  typography = list(
    fontFamily = "'Segoe UI', system-ui, sans-serif"
  ),
  components = list(
    MuiCssBaseline = list(
      styleOverrides = list(
        a = list(color = sw_yellow, "&:hover" = list(color = "white")),
        pre = list(
          background = "#111 !important",
          color = paste0(sw_text, " !important"),
          border = "1px solid #333"
        )
      )
    )
  )
)

# bold label helper
sw_label <- function(label) {
  Box(component = "span", sx = list(fontWeight = "bold"), label)
}

# -- Film poster images (Wikipedia) -------------------------------------------
film_posters <- c(
  `1` = "https://upload.wikimedia.org/wikipedia/en/8/87/StarWarsMoviePoster1977.jpg",
  `2` = "https://upload.wikimedia.org/wikipedia/en/3/3f/The_Empire_Strikes_Back_%281980_film%29.jpg",
  `3` = "https://upload.wikimedia.org/wikipedia/en/b/b2/ReturnOfTheJediPoster1983.jpg",
  `4` = "https://upload.wikimedia.org/wikipedia/en/4/40/Star_Wars_Phantom_Menace_poster.jpg",
  `5` = "https://upload.wikimedia.org/wikipedia/en/3/32/Star_Wars_-_Episode_II_Attack_of_the_Clones_%28movie_poster%29.jpg",
  `6` = "https://upload.wikimedia.org/wikipedia/en/9/93/Star_Wars_Episode_III_Revenge_of_the_Sith_poster.jpg"
)

# helper: film card for the home grid
film_card <- function(id) {
  Grid(
    size = list(xs = 6, sm = 4, md = 2),
    Box(
      component = "a",
      href = paste0("#/films/", id),
      sx = list(textDecoration = "none"),
      Card(
        sx = list(
          cursor = "pointer",
          transition = "transform .15s",
          "&:hover" = list(
            transform = "translateY(-4px)",
            borderColor = sw_yellow
          )
        ),
        CardMedia(
          component = "img",
          image = film_posters[as.character(id)],
          sx = list(aspectRatio = "2/3", objectFit = "cover")
        ),
        CardContent(
          sx = list(textAlign = "center", py = 1),
          Typography(
            paste("Episode", id),
            sx = list(color = sw_yellow, fontWeight = 600)
          )
        )
      )
    )
  )
}

# -- JS loaders: fetch Star Wars data from SWAPI ------------------------------

loader_all_films <- JS(
  "
  async () => {
    const res  = await fetch('https://swapi.info/api/films');
    const data = await res.json();
    return { films: data, total: data.length };
  }
"
)

loader_film <- JS(
  "
  async ({ params }) => {
    // Fetch a single film using the dynamic :id route param (e.g. /films/1)
    const res = await fetch(`https://swapi.info/api/films/${params.id}`);
    // Throw a Response error for useRouteError to catch if the film doesn't exist
    if (!res.ok) throw new Response('Film not found', { status: res.status });
    const data = await res.json();
    // The film response includes a `characters` array of URLs.
    // Fetch all characters in parallel.
    const chars = await Promise.all(data.characters.map(u => fetch(u).then(r => r.json())));
    // SWAPI returns height/mass as strings (e.g. '172'); coerce to numbers
    // so MUI DataGrid and BarChart can sort/render them correctly.
    // `|| 0` handles 'unknown' values that would otherwise become NaN.
    chars.forEach(c => { c.height = Number(c.height) || 0; c.mass = Number(c.mass) || 0; });
    // Attach characters to the film object so the UI can access them
    // via useLoaderData(..., selector = '_characters')
    data._characters = chars;
    return data;
  }
"
)

loader_people <- JS(
  "
  async ({ request }) => {
    const url    = new URL(request.url);
    const search = url.searchParams.get('search') || '';
    const res    = await fetch('https://swapi.info/api/people');
    let data     = await res.json();
    if (search) {
      const q = search.toLowerCase();
      data = data.filter(item => String(item.name || '').toLowerCase().includes(q));
    }
    return { people: data, total: data.length };
  }
"
)

loader_person <- JS(
  "
  async ({ params }) => {
    const res = await fetch(`https://swapi.info/api/people/${params.id}`);
    if (!res.ok) throw new Response('Character not found', { status: res.status });
    const data = await res.json();
    if (data.homeworld) {
      data._homeworld = await fetch(data.homeworld).then(r => r.json()).then(d => d.name);
    }
    // Coerce height/mass to numbers (SWAPI returns strings)
    data.height = Number(data.height) || 0;
    data.mass   = Number(data.mass)   || 0;
    return data;
  }
"
)

# -- Error element -------------------------------------------------------------
error_el <- Box(
  sx = list(textAlign = "center", py = 8, px = 3),
  Typography(
    "Disturbance in the Force",
    variant = "h4",
    sx = list(color = sw_yellow, mb = 2)
  ),
  Typography(
    variant = "body1",
    sx = list(color = "#999", mb = 2),
    "Error: ",
    useRouteError(tags$span(), selector = "statusText")
  ),
  NavLink(to = "/", style = sprintf("color:%s;", sw_yellow), "Return to base")
)

# -- Layout shell (root) -------------------------------------------------------
root_element <- ThemeProvider(
  theme = sw_mui_theme,
  CssBaseline(),
  AppBar(
    position = "static",
    sx = list(borderBottom = paste0("2px solid ", sw_yellow)),
    Toolbar(
      Typography(
        variant = "h6",
        sx = list(
          color = sw_yellow,
          fontWeight = 700,
          letterSpacing = 1,
          mr = 3
        ),
        NavLink(
          to = "/",
          style = "text-decoration:none; color:inherit;",
          "STAR WARS EXPLORER"
        )
      ),
      NavLink(
        to = "/",
        "Films",
        style = JS(
          "function(args) {
            return {
              color: args.isActive ? '#FFE81F' : '#c7c7c7',
              textDecoration: 'none',
              marginRight: 16
            };
          }"
        )
      ),
      NavLink(
        to = "/people",
        "Characters",
        style = JS(
          "function(args) {
            return {
              color: args.isActive ? '#FFE81F' : '#c7c7c7',
              textDecoration: 'none'
            };
          }"
        )
      ),
      Box(sx = list(flexGrow = 1)),
      Typography(
        variant = "caption",
        sx = list(color = "#666"),
        "Location: ",
        useLocation(tags$span(), selector = "pathname")
      )
    )
  ),
  Box(
    sx = list(
      textAlign = "center",
      py = 0.5,
      color = sw_yellow,
      fontWeight = "bold",
      fontSize = "0.85em"
    ),
    "Navigation: ",
    useNavigation(tags$span(), selector = "state")
  ),
  Container(
    maxWidth = "xl",
    sx = list(py = 2),
    Outlet()
  )
)

# -- Home page: film grid ------------------------------------------------------
home_element <- Box(
  Typography(
    "The Saga",
    variant = "h5",
    sx = list(color = sw_yellow, textAlign = "center", mb = 0.5)
  ),
  Typography(
    variant = "body2",
    sx = list(color = "#888", textAlign = "center", mb = 3),
    useLoaderData(tags$span(), selector = "total"),
    " films loaded from swapi.info"
  ),
  Grid(
    container = TRUE,
    spacing = 2,
    !!!lapply(1:6, film_card)
  )
)

# -- Film detail page ----------------------------------------------------------
film_element <- Box(
  Box(
    sx = list(mb = 2),
    NavLink(
      to = "/",
      style = sprintf("color:%s;", sw_yellow),
      "< Back to films"
    )
  ),
  Grid(
    container = TRUE,
    spacing = 2,
    # Film info card
    Grid(
      size = list(xs = 12, md = 4),
      Card(
        CardHeader(
          title = useLoaderData(
            tags$span(),
            selector = "title"
          ),
          action = Chip(
            label = tagList(
              "Episode ",
              useLoaderData(
                tags$span(),
                selector = "episode_id"
              )
            ),
            sx = list(bgcolor = sw_yellow, color = sw_bg, fontWeight = 600)
          ),
          sx = list(
            "& .MuiCardHeader-title" = list(
              color = sw_yellow,
              fontSize = "1.3em"
            )
          )
        ),
        CardContent(
          Typography(
            sw_label("Director: "),
            useLoaderData(tags$span(), selector = "director")
          ),
          Typography(
            sw_label("Producer: "),
            useLoaderData(tags$span(), selector = "producer")
          ),
          Typography(
            sw_label("Release: "),
            useLoaderData(tags$span(), selector = "release_date")
          ),
          Divider(sx = list(my = 1.5, borderColor = "#333")),
          Typography(sw_label("Opening Crawl:"), sx = list(mb = 1)),
          Box(
            sx = list(
              color = sw_yellow,
              fontStyle = "italic",
              maxHeight = 200,
              overflowY = "auto",
              whiteSpace = "pre-line",
              lineHeight = 1.6
            ),
            useLoaderData(
              tags$span(),
              selector = "opening_crawl"
            )
          )
        )
      )
    ),
    # Characters table card
    Grid(
      size = list(xs = 12, md = 4),
      Card(
        CardHeader(
          title = "Characters",
          sx = list("& .MuiCardHeader-title" = list(color = sw_yellow))
        ),
        CardContent(
          Typography(
            "Characters from this film:",
            variant = "caption",
            sx = list(color = "#888", display = "block", mb = 1)
          ),
          Box(
            sx = list(height = 380, width = "100%"),
            useLoaderData(
              muiDataGrid::DataGrid(
                columns = list(
                  list(field = "name", headerName = "Name", flex = 1),
                  list(field = "height", headerName = "Height", width = 90),
                  list(field = "mass", headerName = "Mass", width = 90),
                  list(field = "gender", headerName = "Gender", width = 100)
                ),
                getRowId = JS("function(row) { return row.name }"),
                hideFooter = TRUE,
                disableColumnMenu = TRUE
              ),
              as = "rows",
              selector = "_characters"
            )
          )
        )
      )
    ),
    # Character physique chart card
    Grid(
      size = list(xs = 12, md = 4),
      Card(
        CardHeader(
          title = "Character Physique",
          sx = list("& .MuiCardHeader-title" = list(color = sw_yellow))
        ),
        CardContent(
          useLoaderData(
            as = "dataset",
            selector = "_characters",
            into = muiCharts::BarChart(
              series = list(
                list(
                  dataKey = "height",
                  label = "Height (cm)",
                  color = sw_yellow
                ),
                list(dataKey = "mass", label = "Mass (kg)", color = "#4a4a6a")
              ),
              xAxis = list(
                list(
                  scaleType = "band",
                  dataKey = "name",
                  tickLabelStyle = list(fontSize = 11, angle = -30)
                )
              ),
              height = 350,
              grid = list(horizontal = TRUE),
              sx = list(
                "& .MuiChartsAxis-line" = list(stroke = "#555"),
                "& .MuiChartsAxis-tick" = list(stroke = "#555"),
                "& .MuiChartsAxis-tickLabel" = list(fill = "white"),
                "& .MuiChartsLegend-label" = list(fill = "white"),
                "& .MuiChartsTooltip-root" = list(color = "white")
              )
            )
          )
        )
      )
    )
  ),
  Accordion(
    sx = list(mt = 2, bgcolor = sw_card),
    AccordionSummary(
      expandIcon = Icon("expand_more", sx = list(color = sw_yellow)),
      Typography("Raw API Response (JSON)", sx = list(color = sw_yellow))
    ),
    AccordionDetails(
      Box(
        component = "pre",
        sx = list(maxHeight = 400, overflowY = "auto"),
        useLoaderData(tags$span())
      )
    )
  )
)

# -- People list page ----------------------------------------------------------
people_element <- Box(
  Typography(
    "Characters",
    variant = "h5",
    sx = list(color = sw_yellow, mb = 2)
  ),
  # Search info
  Paper(
    sx = list(p = 2, mb = 2, display = "flex", gap = 2, alignItems = "center"),
    Typography(variant = "body2", sx = list(color = "#888"), "Search query: "),
    Typography(
      variant = "body2",
      sx = list(fontWeight = "bold"),
      useSearchParams(tags$span(), param = "search")
    ),
    Typography(
      variant = "body2",
      sx = list(color = "#888", ml = 2),
      "Results: "
    ),
    Typography(
      variant = "body2",
      sx = list(fontWeight = "bold"),
      useLoaderData(tags$span(), selector = "total")
    )
  ),
  # Search bar
  Form(
    method = "get",
    action = "/people",
    style = "display:flex; gap:8px; margin-bottom:16px;",
    InputBase(
      type = "search",
      name = "search",
      placeholder = "Search characters...",
      sx = list(
        flex = 1,
        px = 1.5,
        py = 1,
        bgcolor = "#111",
        color = sw_text,
        border = "1px solid #333",
        borderRadius = 1.5
      ),
      defaultValue = JS(
        "new URLSearchParams(window.location.hash.split('?')[1] || '').get('search') || ''"
      )
    ),
    Button(
      type = "submit",
      variant = "contained",
      sx = list(
        bgcolor = sw_yellow,
        color = sw_bg,
        fontWeight = 600,
        borderRadius = 1.5,
        "&:hover" = list(bgcolor = "#e6d01b")
      ),
      "Search"
    )
  ),
  # Quick filter links
  Stack(
    direction = "row",
    spacing = 2,
    sx = list(mb = 2, alignItems = "center"),
    Typography(variant = "body2", sx = list(color = "#888"), "Quick filters:"),
    NavLink(to = "/people?search=sky", "Skywalker"),
    NavLink(to = "/people?search=darth", "Darth"),
    NavLink(to = "/people?search=solo", "Solo"),
    NavLink(to = "/people", "Show All")
  ),
  # Character grid
  Box(
    sx = list(height = 500, width = "100%"),
    useLoaderData(
      muiDataGrid::DataGrid(
        columns = list(
          list(
            field = "name",
            headerName = "Name",
            flex = 1,
            renderCell = JS(
              "function(params) {
                return React.createElement('a', {
                  href: '#/people/' + params.id,
                  style: { color: '#FFE81F', textDecoration: 'none', fontWeight: 600 }
                }, params.value);
              }"
            )
          ),
          list(field = "height", headerName = "Height", width = 90),
          list(field = "mass", headerName = "Mass", width = 90),
          list(field = "gender", headerName = "Gender", width = 110)
        ),
        getRowId = JS(
          "function(row) { return row.url.match(/\\/(\\d+)\\/?$/)[1] }"
        ),
        onRowClick = JS(
          "function(params) { window.location.hash = '#/people/' + params.id; }"
        ),
        pageSizeOptions = list(10, 25, 50),
        initialState = list(
          pagination = list(paginationModel = list(pageSize = 10))
        ),
        sx = list(
          cursor = "pointer",
          "& .MuiDataGrid-row:hover" = list(
            backgroundColor = "#252540 !important"
          )
        )
      ),
      as = "rows",
      selector = "people"
    )
  ),
  Outlet()
)

# -- Person detail page --------------------------------------------------------
person_element <- Box(
  Box(
    sx = list(mb = 2),
    NavLink(
      to = "/people",
      style = sprintf("color:%s;", sw_yellow),
      "< Back to characters"
    )
  ),
  Card(
    CardHeader(
      title = useLoaderData(
        tags$span(),
        selector = "name"
      ),
      sx = list(
        "& .MuiCardHeader-title" = list(
          color = sw_yellow,
          fontSize = "1.3em"
        )
      )
    ),
    CardContent(
      Grid(
        container = TRUE,
        spacing = 2,
        Grid(
          size = list(xs = 12, sm = 4),
          Typography(
            sw_label("Height: "),
            useLoaderData(tags$span(), selector = "height"),
            " cm"
          ),
          Typography(
            sw_label("Mass: "),
            useLoaderData(tags$span(), selector = "mass"),
            " kg"
          ),
          Typography(
            sw_label("Birth Year: "),
            useLoaderData(tags$span(), selector = "birth_year")
          )
        ),
        Grid(
          size = list(xs = 12, sm = 4),
          Typography(
            sw_label("Hair: "),
            useLoaderData(tags$span(), selector = "hair_color")
          ),
          Typography(
            sw_label("Eyes: "),
            useLoaderData(tags$span(), selector = "eye_color")
          ),
          Typography(
            sw_label("Skin: "),
            useLoaderData(tags$span(), selector = "skin_color")
          )
        ),
        Grid(
          size = list(xs = 12, sm = 4),
          Typography(
            sw_label("Gender: "),
            useLoaderData(tags$span(), selector = "gender")
          ),
          Typography(
            sw_label("Homeworld: "),
            useLoaderData(tags$span(), selector = "_homeworld")
          )
        )
      )
    )
  ),
  Card(
    sx = list(mt = 2),
    CardHeader(
      title = "Physical Stats",
      sx = list("& .MuiCardHeader-title" = list(color = sw_yellow))
    ),
    CardContent(
      Grid(
        container = TRUE,
        spacing = 2,
        Grid(
          size = list(xs = 12, sm = 6),
          sx = list(textAlign = "center"),
          Typography("Height", sx = list(color = sw_yellow, fontWeight = 600)),
          useLoaderData(
            muiCharts::Gauge(
              valueMax = 264,
              height = 180,
              startAngle = -110,
              endAngle = 110,
              innerRadius = "70%",
              outerRadius = "100%",
              cornerRadius = 6,
              sx = list(
                "& .MuiGauge-valueArc" = list(fill = sw_yellow),
                "& .MuiGauge-referenceArc" = list(fill = "#333"),
                "& .MuiGauge-valueText text" = list(fill = "white")
              )
            ),
            as = "value",
            selector = "height"
          ),
          Typography(
            variant = "body2",
            sx = list(color = "#888"),
            useLoaderData(tags$span(), selector = "height"),
            " cm"
          )
        ),
        Grid(
          size = list(xs = 12, sm = 6),
          sx = list(textAlign = "center"),
          Typography("Mass", sx = list(color = sw_yellow, fontWeight = 600)),
          useLoaderData(
            muiCharts::Gauge(
              valueMax = 200,
              height = 180,
              startAngle = -110,
              endAngle = 110,
              innerRadius = "70%",
              outerRadius = "100%",
              cornerRadius = 6,
              sx = list(
                "& .MuiGauge-valueArc" = list(fill = "#4a4a6a"),
                "& .MuiGauge-referenceArc" = list(fill = "#333"),
                "& .MuiGauge-valueText text" = list(fill = "white")
              )
            ),
            as = "value",
            selector = "mass"
          ),
          Typography(
            variant = "body2",
            sx = list(color = "#888"),
            useLoaderData(tags$span(), selector = "mass"),
            " kg"
          )
        )
      )
    )
  ),
  Accordion(
    sx = list(mt = 2, bgcolor = sw_card),
    AccordionSummary(
      expandIcon = Icon("expand_more", sx = list(color = sw_yellow)),
      Typography("Raw API Response (JSON)", sx = list(color = sw_yellow))
    ),
    AccordionDetails(
      Box(
        component = "pre",
        sx = list(maxHeight = 400, overflowY = "auto"),
        useLoaderData(tags$span())
      )
    )
  )
)

# -- Router --------------------------------------------------------------------
ui <- muiMaterialPage(
  useMaterialIconsFilled = TRUE,
  RouterProvider(
    fallbackElement = tags$div(
      style = "max-width: 480px; margin: 0 auto; padding: 40px; color: gray;",
      tags$h2("Loading application...")
    ),
    Route(
      path = "/",
      element = root_element,
      Route(
        index = TRUE,
        loader = loader_all_films,
        element = home_element
      ),
      Route(
        path = "films/:id",
        loader = loader_film,
        element = film_element,
        errorElement = error_el
      ),
      Route(
        path = "people",
        loader = loader_people,
        element = people_element,
        Route(
          path = ":id",
          loader = loader_person,
          element = person_element,
          errorElement = error_el
        )
      )
    )
  )
)

# htmltools::save_html(ui, "index.html")
htmltools::browsable(ui)
