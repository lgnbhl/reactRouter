# useFetchers() returns all currently active fetchers.
# Useful for a global loading indicator: if any fetcher is busy, show a spinner.
#
# This example runs three FetcherForm searches with different keys.
# useFetchers(selector = "state") maps over all active fetchers and returns
# their states as a JSON array.

library(reactRouter)
library(htmltools)
library(jsonlite)

people_json <- jsonlite::toJSON(
  data.frame(name = c("Alice", "Bob", "Charlie", "David", "Eve")),
  dataframe = "rows",
  auto_unbox = TRUE
)

loader_js <- JS(sprintf(
  "async ({ request }) => {
    await new Promise(r => setTimeout(r, 1000));
    const q = new URL(request.url).searchParams.get('q') || '';
    const db = %s;
    return db.filter(r => r.name.toLowerCase().includes(q.toLowerCase()));
  }",
  people_json
))

ui <- RouterProvider(
  Route(
    path = "/",
    element = div(
      tags$h2("useFetchers Example — Global Loading Indicator"),
      tags$p(
        "Submit one or more search forms. Each uses a different fetcher key. ",
        "useFetchers() tracks all of them.",
        style = "color: #555;"
      ),
      tags$p(
        tags$strong("All fetcher states: "),
        useFetchers(tags$code(), selector = "state")
      ),
      tags$hr(),

      tags$h3("Search A"),
      FetcherForm(
        fetcherKey = "search-a", method = "get", action = "/search",
        style = "display: flex; gap: 8px; margin-bottom: 8px;",
        tags$input(type = "search", name = "q", placeholder = "Name...",
          style = "padding: 4px;"),
        tags$button(type = "submit", "Search A", style = "cursor: pointer;")
      ),
      tags$p("State A: ", useFetcher(tags$code(), fetcherKey = "search-a", selector = "state")),
      tags$p("Results A: ", useFetcher(tags$span(), fetcherKey = "search-a", selector = "data")),

      tags$h3("Search B"),
      FetcherForm(
        fetcherKey = "search-b", method = "get", action = "/search",
        style = "display: flex; gap: 8px; margin-bottom: 8px;",
        tags$input(type = "search", name = "q", placeholder = "Name...",
          style = "padding: 4px;"),
        tags$button(type = "submit", "Search B", style = "cursor: pointer;")
      ),
      tags$p("State B: ", useFetcher(tags$code(), fetcherKey = "search-b", selector = "state")),
      tags$p("Results B: ", useFetcher(tags$span(), fetcherKey = "search-b", selector = "data")),

      tags$hr(),
      Outlet()
    ),
    Route(index = TRUE, element = div()),
    Route(
      path = "search",
      loader = loader_js,
      element = div()
    )
  )
)

# htmltools::save_html(ui, "index.html")
htmltools::browsable(ui)
