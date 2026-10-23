library(shiny)

ui <- reactRouter::RouterProvider(
  router = reactRouter::createHashRouter(
    reactRouter::Route(
      path = "/",
      element = div(reactRouter::Outlet()),
      reactRouter::Route(
        path = "products/:id",
        element = div(
          div(
            id = "actionDefault",
            reactRouter::useFormAction(tags$span())
          ),
          div(
            id = "actionChild",
            reactRouter::useFormAction(tags$span(), action = "edit")
          ),
          div(
            id = "actionParentRoute",
            reactRouter::useFormAction(tags$span(), action = "..")
          ),
          div(
            id = "actionParentPath",
            reactRouter::useFormAction(tags$span(), action = "..", relative = "path")
          ),
          tags$form(
            id = "formInto",
            method = "post",
            reactRouter::useFormAction(
              tags$span(),
              as = "data-action",
              action = "edit"
            )
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {}

shinyApp(ui, server)
