library(shiny)

ui <- fluidPage(
  reactRouter::createHashRouter(
    reactRouter::createRoutesFromElements(
      reactRouter::Route(
        id = "root",
        path = "/",
        loader = reactRouter::JS("async () => { return { loaded: true }; }"),
        element = div(
          div(
            id = "matchesAll",
            reactRouter::useMatches(
              tags$span()
            )
          ),
          reactRouter::Outlet()
        ),
        reactRouter::Route(
          path = "form",
          action = reactRouter::JS(
            "async ({ request }) => {
              const formData = await request.formData();
              return { submitted: formData.get('name') };
            }"
          ),
          element = div(
            div(
              id = "actionData",
              reactRouter::useActionData(
                tags$span()
              )
            ),
            div(
              id = "actionField",
              reactRouter::useActionData(
                tags$span(),
                selector = "submitted"
              )
            ),
            reactRouter::Form(
              method = "post",
              tags$input(type = "hidden", name = "name", value = "Bob"),
              tags$button(id = "submitBtn", type = "submit", "Submit")
            )
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {}

shinyApp(ui, server)
