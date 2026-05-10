# dataResponse() — wraps a loader/action payload with HTTP status, statusText
# and headers, while still exposing the value via useLoaderData() /
# useActionData(). Useful when you want to attach metadata to the
# response without changing how the route's element consumes it.
#
# Two routes:
#   /profile  — static loader built with the R helper dataResponse()
#   /custom   — custom loader using window.jsmodule['@/reactRouter'].helpers.data() to
#               attach a 201 status to a computed payload.

library(reactRouter)
library(htmltools)

custom_loader <- JS(
  "() => {
     const payload = { greeting: 'hello', generatedAt: new Date().toISOString() };
     return window.jsmodule['@/reactRouter'].helpers.data(payload, {
       status: 201,
       headers: { 'X-Built-With': 'reactRouter R' }
     });
   }"
)

Layout <- div(
  style = "max-width: 540px; margin: 0 auto; padding: 20px; font-family: system-ui;",
  tags$h2("dataResponse() Example"),
  tags$nav(tags$ul(
    tags$li(NavLink(to = "/", "Home")),
    tags$li(NavLink(to = "/profile", "/profile (static R object)")),
    tags$li(NavLink(to = "/custom", "/custom (computed in JS)"))
  )),
  tags$hr(),
  Outlet()
)

ui <- RouterProvider(
  router = createHashRouter(
    Route(
      path = "/",
      element = Layout,
      Route(index = TRUE, element = tags$p("Pick a link above.")),
      Route(
        path = "profile",
        loader = dataResponse(
          list(name = "Ada Lovelace", role = "Engineer", years = 12),
          init = list(status = 200)
        ),
        element = div(
          tags$h3("Profile"),
          useLoaderData(tags$pre(style = "background:#f8f9fa;padding:10px;"))
        )
      ),
      Route(
        path = "custom",
        loader = custom_loader,
        element = div(
          tags$h3("Custom"),
          tags$p(tags$strong("Greeting: "), useLoaderData(tags$span(), selector = "greeting")),
          tags$p(tags$strong("Generated at: "), useLoaderData(tags$span(), selector = "generatedAt"))
        )
      )
    )
  )
)

# htmltools::save_html(ui, "index.html")
htmltools::browsable(ui)
