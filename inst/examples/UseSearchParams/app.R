# Minimal example showing useSearchParams() which exposes useSearchParams()
# useSearchParams reads URL query parameters (read-only)

library(reactRouter)
library(htmltools)

Layout <- div(
  tags$h2("useSearchParams Example"),
  tags$nav(tags$ul(
    tags$li(NavLink(to = "/?color=red", "Red")),
    tags$li(NavLink(to = "/?color=blue&size=large", "Blue Large")),
    tags$li(NavLink(to = "/?tag=news&tag=sports&tag=tech", "Multiple tags")),
    tags$li(NavLink(to = "/", "Clear"))
  )),
  tags$hr(),
  tags$h3("color param (single value):"),
  useSearchParams(tags$span(), param = "color"),
  tags$h3("size param (often absent):"),
  useSearchParams(tags$span(style = "color: gray"), param = "size"),
  tags$h3("tag param (can repeat):"),
  useSearchParams(tags$span(), param = "tag"),
  tags$h3("tag param, rendered as a list:"),
  useSearchParams(
    param = "tag",
    render = JS(
      "(tags) => tags.length
        ? React.createElement('ul', null, tags.map((t, i) =>
            React.createElement('li', { key: i }, t)))
        : React.createElement('em', null, '(none)')"
    )
  ),
  Outlet()
)

ui <- RouterProvider(
  router = createHashRouter(
    Route(
      path = "/",
      element = Layout,
      Route(index = TRUE, element = div(tags$p("Home page")))
    )
  )
)

# htmltools::save_html(ui, "index.html")
htmltools::browsable(ui)
