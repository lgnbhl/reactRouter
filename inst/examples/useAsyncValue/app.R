# useAsyncValue() — reads the resolved value of the closest <Await>.
# Used in "children mode" of Await(): when no `into` / `render` is
# given on Await, its children are rendered as descendants of the
# underlying React Router <Await>, and useAsyncValue() picks up the
# resolved promise value for any node beneath it.

library(reactRouter)
library(htmltools)

Layout <- div(
  style = "max-width: 560px; margin: 0 auto; padding: 20px; font-family: system-ui;",
  tags$h2("useAsyncValue Example"),
  tags$nav(tags$ul(
    tags$li(NavLink(to = "/", "Home")),
    tags$li(NavLink(to = "/report", "Report (deferred)"))
  )),
  tags$hr(),
  Outlet()
)

ui <- RouterProvider(
  router = createMemoryRouter(
    Route(
      path = "/",
      element = Layout,
      Route(index = TRUE, element = tags$p("Open the Report tab.")),
      Route(
        path = "report",
        loader = JS(
          "async () => ({
             metrics: new Promise((resolve) =>
               setTimeout(() => resolve({
                 revenue: '$1,240,000',
                 users:   '18,430',
                 growth:  '+14.2%'
               }), 1500)
             )
           })"
        ),
        element = div(
          tags$h3("Quarterly Metrics"),
          # Children-mode Await: no into/render, the children are rendered
          # inside <Await> so descendants can call useAsyncValue().
          Await(
            resolveKey = "metrics",
            fallback = tags$em(style = "color:gray;", "loading…"),
            div(
              style = "background:#f8f9fa; padding:12px; border-radius:6px;",
              tags$p(tags$strong("Revenue: "), useAsyncValue(tags$span(), selector = "revenue")),
              tags$p(tags$strong("Users: "),   useAsyncValue(tags$span(), selector = "users")),
              tags$p(tags$strong("Growth: "),  useAsyncValue(tags$span(), selector = "growth")),
              tags$hr(),
              tags$p(
                tags$strong("Whole object: "),
                useAsyncValue(tags$pre(style = "background:#fff;padding:8px;"))
              )
            )
          )
        )
      )
    )
  )
)

# htmltools::save_html(ui, "index.html")
htmltools::browsable(ui)
