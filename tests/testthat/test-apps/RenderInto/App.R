library(shiny)

# The loader waits 1.5 s and prefixes each id with `srv:`, so a bare id can
# only come from the pending URL read through useNavigation() in `render`.
optimistic <- reactRouter::JS("(data, el) => {
  const { useNavigation, useLocation } = window.jsmodule['react-router-dom'];
  const navigation = useNavigation();
  const location = useLocation();
  const next = navigation.location;
  let ids = data.selected;
  if (next && next.pathname === location.pathname) {
    const params = new URLSearchParams(next.search);
    if (params.has('ids')) ids = params.get('ids').split(',').filter(Boolean);
  }
  return window.jsmodule['react'].cloneElement(el, { children: ids.join(', ') });
}")

ui <- reactRouter::RouterProvider(
  router = reactRouter::createHashRouter(
    reactRouter::Route(
      path = "/",
      element = div(
        # `useMatch` returns null off "/list", which skips `render`; the
        # hooks `render` calls must not change the wrapper's hook count.
        div(
          id = "matchHooks",
          reactRouter::useMatch(
            pattern = "/list",
            render = reactRouter::JS("m => {
              const { useNavigation } = window.jsmodule['react-router-dom'];
              return 'match:' + useNavigation().state;
            }")
          )
        ),
        reactRouter::Outlet()
      ),
      reactRouter::Route(
        path = "list",
        loader = reactRouter::JS(
          "async ({ request }) => {
            await new Promise(r => setTimeout(r, 1500));
            const ids = new URL(request.url).searchParams.get('ids') || '';
            return { selected: ids.split(',').filter(Boolean).map(s => 'srv:' + s) };
          }"
        ),
        element = div(
          div(
            id = "plain",
            reactRouter::useLoaderData(tags$span(), selector = "selected")
          ),
          div(
            id = "optimistic",
            reactRouter::useLoaderData(tags$span(), render = optimistic)
          ),
          div(
            id = "extraProps",
            reactRouter::useLoaderData(
              tags$span(),
              title = "extra",
              render = reactRouter::JS("(d, el) => el")
            )
          ),
          div(
            id = "searchInto",
            reactRouter::useSearchParams(
              tags$span(),
              param = "ids",
              render = reactRouter::JS(
                "(v, set, el) => window.jsmodule['react'].cloneElement(el,
                   { children: typeof set + ':' + v.join('|') })"
              )
            )
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {}

shinyApp(ui, server)
