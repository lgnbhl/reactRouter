# ScrollRestoration example
# Demonstrates ScrollRestoration() which restores the window scroll position
# when navigating between pages, mimicking native browser behaviour.
# Place <ScrollRestoration /> once inside the root layout of a data router app.

library(reactRouter)
library(htmltools)

# Helper to build a long page so scrolling is visible
long_page <- function(title, color) {
  items <- lapply(seq_len(30), function(i) {
    tags$p(
      style = paste0(
        "padding: 6px 10px; background:",
        color,
        "; border-radius: 4px;"
      ),
      paste("Item", i, "—", title)
    )
  })
  div(
    tags$h3(title),
    tags$p(
      style = "color: gray; font-size: 0.9em;",
      "Scroll down, then navigate away and come back — your position is restored."
    ),
    do.call(div, items)
  )
}

Layout <- div(
  style = "max-width: 520px; margin: 0 auto; padding: 20px; font-family: system-ui;",
  tags$h2("ScrollRestoration Example"),
  tags$nav(tags$ul(
    tags$li(NavLink(to = "/", "Home (long)")),
    tags$li(NavLink(to = "/news", "News (long)")),
    tags$li(NavLink(to = "/about", "About (short)"))
  )),
  tags$hr(),
  # ScrollRestoration must be rendered inside the router layout
  ScrollRestoration(),
  Outlet()
)

ui <- RouterProvider(
  Route(
    path = "/",
    element = Layout,
    Route(index = TRUE, element = long_page("Home", "#e8f4fd")),
    Route(path = "news", element = long_page("News", "#fdf6e8")),
    Route(
      path = "about",
      element = div(
        tags$h3("About"),
        tags$p(
          "This page is short — scrolling back to 'Home' or 'News' restores your previous position."
        )
      )
    )
  )
)

# htmltools::save_html(ui, "index.html")
htmltools::browsable(ui)
