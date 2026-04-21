# Minimal example showing useNavigation() which exposes useNavigation()
# useNavigation returns the navigation state: "idle", "loading", or "submitting"

library(reactRouter)
library(htmltools)

ui <- RouterProvider(
  router = createHashRouter(
    Route(
      path = "/",
      element = div(
        tags$h2("useNavigation Example"),
        tags$nav(tags$ul(
          tags$li(NavLink(to = "/", "Home")),
          tags$li(NavLink(to = "/slow", "Slow Page (2s)"))
        )),
        tags$p(
          tags$strong("Navigation state: "),
          useNavigation(tags$span(), selector = "state")
        ),
        tags$hr(),
        Outlet()
      ),
      Route(
        index = TRUE,
        element = div(tags$p(
          "Home page. Click 'Slow Page' to see loading state."
        ))
      ),
      Route(
        path = "slow",
        loader = JS(
          "async () => {
            await new Promise(r => setTimeout(r, 2000));
            return { message: 'Data loaded after 2 seconds!' };
          }"
        ),
        element = div(
          tags$h3("Slow Page"),
          tags$p(useLoaderData(
            tags$span(),
            selector = "message"
          ))
        )
      )
    )
  )
)

# htmltools::save_html(ui, "index.html")
htmltools::browsable(ui)
