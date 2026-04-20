# useOutletContext() reads a context value passed through Outlet(context = ...).
# The parent route sets context; any child route reads it without prop-drilling.
# Useful for sharing user info, theme settings, or any route-scoped data.

library(reactRouter)
library(htmltools)

# Simulated current user passed from the parent layout to all child routes
current_user <- list(
  name = "Alice",
  role = "admin",
  email = "alice@example.com"
)

ui <- RouterProvider(
  router = createMemoryRouter(
    Route(
      path = "/",
      element = div(
        style = "max-width: 520px; margin: 0 auto; padding: 20px; font-family: system-ui;",
        tags$h2("useOutletContext Example"),
        tags$nav(tags$ul(
          tags$li(NavLink(to = "/", "Dashboard")),
          tags$li(NavLink(to = "/profile", "Profile")),
          tags$li(NavLink(to = "/settings", "Settings"))
        )),
        tags$hr(),
        # Pass user info to all child routes via context
        Outlet(context = current_user)
      ),
      Route(
        index = TRUE,
        element = div(
          tags$h3("Dashboard"),
          tags$p(
            "Welcome back, ",
            tags$strong(useOutletContext(tags$span(), selector = "name")),
            "!"
          ),
          tags$p(
            "Your role: ",
            useOutletContext(tags$code(), selector = "role")
          )
        )
      ),
      Route(
        path = "profile",
        element = div(
          tags$h3("Profile"),
          tags$p("Name:  ", useOutletContext(tags$span(), selector = "name")),
          tags$p("Email: ", useOutletContext(tags$span(), selector = "email")),
          tags$p("Role:  ", useOutletContext(tags$span(), selector = "role")),
          tags$details(
            tags$summary("Full context (JSON)"),
            tags$pre(useOutletContext(tags$span()))
          )
        )
      ),
      Route(
        path = "settings",
        element = div(
          tags$h3("Settings"),
          tags$p(
            "Editing settings for ",
            tags$strong(useOutletContext(tags$span(), selector = "name"))
          )
        )
      )
    )
  )
)

# htmltools::save_html(ui, "index.html")
htmltools::browsable(ui)
