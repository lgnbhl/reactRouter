# Await example — classic into= mode
# Demonstrates Await() which renders content once a deferred loader promise
# resolves, enabling non-blocking ("streaming") data loading.
#
# The loader returns a slow promise alongside fast data (no defer() needed in
# React Router v7 — just return the object directly). The fast data renders
# immediately; Await() waits for the slow promise and streams in the result
# without blocking the page transition.
#

library(reactRouter)
library(htmltools)

Layout <- div(
  style = "max-width: 560px; margin: 0 auto; padding: 20px; font-family: system-ui;",
  tags$h2("Await Example"),
  tags$nav(tags$ul(
    tags$li(NavLink(to = "/", "Dashboard")),
    tags$li(NavLink(to = "/report", "Monthly Report (deferred)"))
  )),
  tags$hr(),
  Outlet()
)

ui <- RouterProvider(
  Route(
    path = "/",
    element = Layout,

    # Index route — instant load
    Route(
      index = TRUE,
      element = div(
        tags$h3("Dashboard"),
        tags$p(
          "Navigate to ",
          tags$strong("Monthly Report"),
          " to see deferred loading."
        ),
        tags$p(
          "The report loader immediately returns fast summary data and ",
          tags$em("defers"),
          " the slower details query (~2 s). The page renders at once;",
          " Await() streams in the deferred metrics when the promise resolves."
        )
      )
    ),

    # Report route — fast summary + slow deferred details
    Route(
      path = "report",
      loader = JS(
        "async () => {
          // Fast data returned immediately
          const summary = { title: 'Q1 2026 Monthly Report', pages: 42 };

          // Slow promise — deferred so the page does not block on it
          const details = new Promise((resolve) =>
            setTimeout(() => resolve({
              revenue:   '$1,240,000',
              users:     '18,430',
              growth:    '+14.2%',
              topRegion: 'EMEA'
            }), 2000)
          );

          return { summary, details };
        }"
      ),
      element = div(
        tags$h3(useLoaderData(tags$span(), selector = "summary.title")),
        tags$p(
          tags$strong("Pages: "),
          useLoaderData(tags$span(), selector = "summary.pages")
        ),
        tags$hr(),

        tags$h4("Detailed metrics (deferred — loads in ~2 s)"),
        tags$p(
          style = "color: gray; font-size: 0.9em;",
          "Below renders once the deferred promise resolves:"
        ),

        # Show each field individually using selector.
        # The `fallback` element is shown while the promise is pending.
        tags$div(
          style = "background: #f8f9fa; padding: 12px; border-radius: 6px;",
          tags$p(
            tags$strong("Revenue: "),
            Await(
              tags$span(),
              resolveKey = "details",
              selector = "revenue",
              fallback = tags$em(style = "color:gray;", "loading…")
            )
          ),
          tags$p(
            tags$strong("Users: "),
            Await(
              tags$span(),
              resolveKey = "details",
              selector = "users",
              fallback = tags$em(style = "color:gray;", "loading…")
            )
          ),
          tags$p(
            tags$strong("Growth: "),
            Await(
              tags$span(),
              resolveKey = "details",
              selector = "growth",
              fallback = tags$em(style = "color:gray;", "loading…")
            )
          ),
          tags$p(
            tags$strong("Top region: "),
            Await(
              tags$span(),
              resolveKey = "details",
              selector = "topRegion",
              fallback = tags$em(style = "color:gray;", "loading…")
            )
          )
        )
      )
    )
  )
)

# htmltools::save_html(ui, "index.html")
htmltools::browsable(ui)
