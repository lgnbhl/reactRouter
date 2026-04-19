# useRevalidator() shows whether the current route's loader is being re-run
# ("idle" or "loading") — without a page-level navigation.
#
# RevalidatorButton() is a <button> that calls revalidator.revalidate() on
# click and is automatically disabled while revalidation is in progress.
#
# A 1-second delay is added to the loader so the "loading" state is visible.

library(reactRouter)
library(htmltools)

ui <- RouterProvider(
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
        useRevalidator(tags$span())
      ),
      RevalidatorButton(
        "Refresh (revalidate loader)",
        style = "padding: 6px 14px; cursor: pointer;"
      ),
      tags$hr(),
      Outlet()
    ),
    Route(index = TRUE, element = div(tags$p("Home page.")))
  )
)

# htmltools::save_html(ui, "index.html")
htmltools::browsable(ui)
