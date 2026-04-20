# RouterProvider example
# Mirrors the React Router v7 composition pattern:
#   RouterProvider(router = createHashRouter(routes), fallbackElement = ...)
# Swap createHashRouter() for createBrowserRouter() or createMemoryRouter()
# to change the routing strategy.
#
# `fallbackElement` is shown while the initial route's loader resolves.

library(reactRouter)
library(htmltools)

Home <- div(
  tags$h3("Home"),
  useLoaderData(tags$p(), selector = "message"),
  tags$p("Built with ", tags$code("createMemoryRouter()"), "."),
  tags$p(
    "Swap it for ",
    tags$code("createHashRouter()"),
    " or ",
    tags$code("createBrowserRouter()"),
    " to change the routing strategy."
  )
)

About <- div(
  tags$h3("About"),
  tags$p(
    "This app composes ",
    tags$code("RouterProvider()"),
    " with ",
    tags$code("createMemoryRouter()"),
    ", matching the official React Router v7 API."
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

ui <- RouterProvider(
  router = createMemoryRouter(
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
  ),
  fallbackElement = tags$div(
    style = "max-width: 480px; margin: 0 auto; padding: 40px; font-family: system-ui; color: gray;",
    tags$h2("Loading application...")
  )
)

# htmltools::save_html(ui, "index.html")
htmltools::browsable(ui)
