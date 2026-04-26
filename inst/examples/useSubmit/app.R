# useSubmit() triggers a form submission programmatically — it invokes
# the route's action() without requiring a <Form> element or even a
# user-visible form. Useful for "quick actions" like delete/confirm
# buttons that still go through React Router's data flow.
#
# Requires a data router (createHashRouter / createBrowserRouter).

library(reactRouter)
library(htmltools)

# Route action: receives the submitted data and returns a message.
# In a real app this would mutate a database / call an API.
action <- JS(
  "async ({ request }) => {
     const form = await request.formData();
     const intent = form.get('intent');
     return { message: `action received intent = ${intent} at ${new Date().toLocaleTimeString()}` };
   }"
)

# render receives the submit function:
#   submit(targetOrFormData, options?)
# Here we submit a plain object as form data with method 'post'.
submit_buttons <- JS(
  "submit => React.createElement('div', null,
    React.createElement('button',
      { onClick: () => submit({ intent: 'like' },   { method: 'post' }) },
      'Like'
    ),
    ' ',
    React.createElement('button',
      { onClick: () => submit({ intent: 'delete' }, { method: 'post' }) },
      'Delete'
    )
  )"
)

Layout <- div(
  style = "max-width: 520px; margin: 0 auto; padding: 20px; font-family: system-ui;",
  tags$h2("useSubmit Example"),
  tags$p(
    style = "color: #555; font-size: 0.9em;",
    "These buttons call ", tags$code("submit()"), " directly. No ",
    tags$code("<Form>"), " element is rendered — the route's ",
    tags$code("action()"), " still runs."
  ),
  useSubmit(render = submit_buttons),
  tags$hr(),
  tags$h3("Last action response:"),
  useActionData(
    tags$pre(style = "background: #f4f4f4; padding: 8px;"),
    selector = "message"
  )
)

ui <- RouterProvider(
  router = createHashRouter(
    Route(
      path = "/",
      action = action,
      element = Layout
    )
  )
)

# htmltools::save_html(ui, "index.html")
htmltools::browsable(ui)
