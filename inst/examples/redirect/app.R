# redirect() returns a JS loader that redirects to another route.
# Use it as a Route's `loader` to build "guard" or "alias" routes that
# always send the user elsewhere.
#
# For conditional redirects inside a custom loader/action, call the
# global `window.reactRouterHelpers.redirect(to)` from your own JS()
# string — see the "conditional" route below.

library(reactRouter)
library(htmltools)

# Conditional redirect written as a custom loader. Flips a coin and
# either redirects to /target or returns some data.
coin_flip_loader <- JS(
  "() => {
     if (Math.random() < 0.5) {
       return window.reactRouterHelpers.redirect('/target');
     }
     return { message: 'You got lucky — no redirect this time.' };
   }"
)

Layout <- div(
  style = "max-width: 540px; margin: 0 auto; padding: 20px; font-family: system-ui;",
  tags$h2("redirect Example"),
  tags$nav(tags$ul(
    tags$li(NavLink(to = "/", "Home")),
    tags$li(NavLink(to = "/old", "/old (always redirects to /target)")),
    tags$li(NavLink(to = "/maybe", "/maybe (50/50 redirect)")),
    tags$li(NavLink(to = "/target", "/target"))
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
      # Static redirect: /old -> /target
      Route(
        path = "old",
        loader = redirect("/target"),
        element = NULL
      ),
      # Conditional redirect using window.reactRouterHelpers.redirect
      Route(
        path = "maybe",
        loader = coin_flip_loader,
        element = div(
          tags$h3("/maybe"),
          useLoaderData(tags$p(), selector = "message")
        )
      ),
      Route(
        path = "target",
        element = tags$h3("/target — you arrived.")
      )
    )
  )
)

# htmltools::save_html(ui, "index.html")
htmltools::browsable(ui)
