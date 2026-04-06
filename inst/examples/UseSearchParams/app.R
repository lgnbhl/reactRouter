# Minimal example showing useSearchParams() which exposes useSearchParams()
# useSearchParams reads URL query parameters (read-only)

library(reactRouter)
library(htmltools)

Layout <- div(
  tags$h2("useSearchParams Example"),
  tags$nav(tags$ul(
    tags$li(NavLink(to = "/?color=red", "Red")),
    tags$li(NavLink(to = "/?color=blue&size=large", "Blue Large")),
    tags$li(NavLink(to = "/", "Clear"))
  )),
  tags$hr(),
  tags$h3("color param:"),
  useSearchParams(tags$span(), param = "color"),
  tags$h3("size param:"),
  useSearchParams(tags$span(), param = "size"),
  Outlet()
)

ui <- RouterProvider(
  Route(
    path = "/",
    element = Layout,
    Route(index = TRUE, element = div(tags$p("Home page")))
  )
)

# htmltools::save_html(ui, "index.html")
htmltools::browsable(ui)
