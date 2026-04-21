# useRevalidator() shows whether the current route's loader is being re-run
# ("idle" or "loading") — without a page-level navigation.
#
# To trigger revalidation, inject the hook's `revalidate` function as the
# `onClick` handler of any element using the generic hook-wrapper pattern:
#   useRevalidator(tags$button(...), as = "onClick", selector = "revalidate")
#
# A 1-second delay is added to the loader so the "loading" state is visible.

library(reactRouter)
library(htmltools)

ui <- RouterProvider(
  router = createHashRouter(
    Route(
      path = "/",
      loader = JS(
        "async () => {
        await new Promise(r => setTimeout(r, 1000));
        return { time: new Date().toLocaleTimeString() };
      }"
      ),
      element = div(
        tags$h2("useRevalidator Example"),
        tags$p(
          "Click the button to re-run the loader and refresh the timestamp. ",
          "The URL and scroll position do not change.",
          style = "color: #555;"
        ),
        tags$p(
          tags$strong("Loaded at: "),
          useLoaderData(tags$span(), selector = "time")
        ),
        tags$p(
          tags$strong("Revalidation state: "),
          useRevalidator(tags$span(), selector = "state")
        ),
        useRevalidator(
          tags$button(
            "Refresh (revalidate loader)",
            style = "padding: 6px 14px; cursor: pointer;"
          ),
          as = "onClick",
          selector = "revalidate"
        ),
        tags$hr(),
        Outlet()
      ),
      Route(index = TRUE, element = div(tags$p("Home page.")))
    )
  )
)

# htmltools::save_html(ui, "index.html")
htmltools::browsable(ui)
