# Inline search using useFetcher() — fetch data without navigating.
#
# Key: use Form(navigate = FALSE, fetcherKey = "...") to submit without a
# page-level navigation. useFetcher() with the same fetcherKey reads that
# fetcher's state and data.
#
# useFetcher() exposes (via selector):
#   state       "idle" | "loading" | "submitting"
#   data.count  value returned by the route loader

library(reactRouter)
library(htmltools)
library(jsonlite)

people_json <- jsonlite::toJSON(
  data.frame(name = c("Alice", "Bob", "Charlie", "David", "Eve")),
  dataframe = "rows",
  auto_unbox = TRUE
)

ui <- RouterProvider(
  router = createMemoryRouter(
    Route(
      path = "/",
      element = div(
        tags$h2("useFetcher Example — Inline Search"),
        tags$p(
          "Type a name and click Search. The URL does not change.",
          style = "color: #555;"
        ),
        # Form with navigate = FALSE submits via a fetcher (no URL change).
        # fetcherKey ties this form to the useFetcher() calls below.
        Form(
          navigate = FALSE,
          fetcherKey = "search",
          method = "get",
          action = "/search",
          style = "display: flex; gap: 8px; margin-bottom: 16px;",
          tags$input(
            type = "search",
            name = "q",
            placeholder = "Search names...",
            style = "padding: 6px; font-size: 14px;"
          ),
          tags$button(
            type = "submit",
            "Search",
            style = "padding: 6px 12px; cursor: pointer;"
          )
        ),
        tags$p(
          tags$strong("Fetcher state: "),
          useFetcher(tags$span(), fetcherKey = "search", selector = "state")
        ),
        tags$p(
          tags$strong("Matches found: "),
          useFetcher(
            tags$span(),
            fetcherKey = "search",
            selector = "data.count"
          )
        ),
        tags$details(
          tags$summary("Raw results (JSON)"),
          tags$pre(useFetcher(
            tags$span(),
            fetcherKey = "search",
            selector = "data.results"
          ))
        ),
        tags$hr(),
        Outlet()
      ),
      Route(
        index = TRUE,
        element = div(
          tags$p("Enter a name above and click Search.")
        )
      ),
      Route(
        path = "search",
        loader = JS(sprintf(
          "async ({ request }) => {
          await new Promise(resolve => setTimeout(resolve, 800));
          const q = new URL(request.url).searchParams.get('q') || '';
          const db = %s;
          const hits = db.filter(r =>
            r.name.toLowerCase().includes(q.toLowerCase())
          );
          return { count: hits.length, results: hits };
        }",
          people_json
        )),
        element = div()
      )
    )
  )
)

# htmltools::save_html(ui, "index.html")
htmltools::browsable(ui)
