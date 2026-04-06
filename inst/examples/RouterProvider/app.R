# RouterProvider example
# Demonstrates RouterProvider() as a unified entry point for data routers.
# The `type` argument selects the router variant: "hash" (default),
# "browser", or "memory" — equivalent to createHashRouter(),
# createBrowserRouter(), and createMemoryRouter() respectively.
#
# Also demonstrates `fallbackElement`, which is shown while the initial
# route and its loader are resolving.

library(reactRouter)
library(htmltools)

Home <- div(
  tags$h3("Home"),
  useLoaderData(tags$p(), selector = "message"),
  tags$p("RouterProvider with ", tags$code('type = "memory"'), "."),
  tags$p(
    "Try changing the ",
    tags$code("type"),
    " argument to ",
    tags$code('"hash"'),
    " (default) or ",
    tags$code('"browser"'),
    "."
  )
)

About <- div(
  tags$h3("About"),
  tags$p(
    "This app uses ",
    tags$code("RouterProvider()"),
    " instead of ",
    tags$code("createHashRouter()"),
    "."
  ),
  tags$p(
    "Both produce the same result — RouterProvider is a single entry",
    " point that picks the underlying router via the ",
    tags$code("type"),
    " prop."
  )
)

Layout <- div(
  style = "max-width: 480px; margin: 0 auto; padding: 20px; font-family: system-ui;",
  tags$h2("RouterProvider Example"),
  tags$nav(tags$ul(
    tags$li(NavLink(to = "/", "Home")),
    tags$li(NavLink(to = "/about", "About"))
  )),
  tags$hr(),
  Outlet()
)

# fallbackElement is displayed while the initial route's loader resolves.
ui <- RouterProvider(
  type = "memory",
  fallbackElement = tags$div(
    style = "max-width: 480px; margin: 0 auto; padding: 40px; font-family: system-ui; color: gray;",
    tags$h2("Loading application...")
  ),
  Route(
    path = "/",
    element = Layout,
    Route(
      index = TRUE,
      loader = JS("async () => {
        await new Promise(r => setTimeout(r, 1500));
        return { message: 'Data loaded after 1.5 s!' };
      }"),
      element = Home
    ),
    Route(path = "about", element = About)
  )
)

# htmltools::save_html(ui, "index.html")
htmltools::browsable(ui)
