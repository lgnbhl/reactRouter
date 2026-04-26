# useSearchParams() — when used with `render`, the JS function receives
# BOTH the current params and a setSearchParams setter as a second
# argument. Use the setter to update the URL's query string
# programmatically (without constructing a new href).

library(reactRouter)
library(htmltools)

# render receives (value, setSearchParams):
#   setSearchParams({ key: value })                 — replace all params
#   setSearchParams(prev => { prev.set(k,v); return prev; })  — update
color_controls <- JS(
  "(value, setSearchParams) => {
     const current = value.color ? value.color.join(', ') : '(none)';
     const setTo = (c) => () => setSearchParams(c ? { color: c } : {});
     return React.createElement('div', null,
       React.createElement('p', null,
         React.createElement('strong', null, 'color: '),
         React.createElement('code', null, current)
       ),
       React.createElement('button', { onClick: setTo('red')   }, 'Set red'),   ' ',
       React.createElement('button', { onClick: setTo('blue')  }, 'Set blue'),  ' ',
       React.createElement('button', { onClick: setTo('green') }, 'Set green'), ' ',
       React.createElement('button', { onClick: setTo(null)    }, 'Clear')
     );
   }"
)

ui <- RouterProvider(
  router = createHashRouter(
    Route(
      path = "/",
      element = div(
        style = "max-width: 520px; margin: 0 auto; padding: 20px; font-family: system-ui;",
        tags$h2("setSearchParams Example"),
        tags$p(
          style = "color: #555; font-size: 0.9em;",
          "Buttons below update the URL query string via ",
          tags$code("setSearchParams"), ". Watch the address bar change."
        ),
        useSearchParams(render = color_controls)
      )
    )
  )
)

# htmltools::save_html(ui, "index.html")
htmltools::browsable(ui)
