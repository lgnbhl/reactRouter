# reactRouter examples

Each subfolder is a runnable example. Launch any of them with:

```r
reactRouter::reactRouterExample("<name>")
# or
shiny::runApp(system.file("examples", "<name>", package = "reactRouter"))
```

The recommended entry point is `RouterProvider()` paired with one of the
`create*Router()` functions. See
`vignette("routers", package = "reactRouter")` for guidance on choosing a
router and `vignette("introduction", package = "reactRouter")` for a tour.

## Showcase

| Example | What it shows |
|---|---|
| [`basic`](basic/) | Layout route, nested routes, `Outlet()`, `Link()`, splat `*` route |
| [`bslib`](bslib/) | reactRouter inside a `bslib::page_navbar()` |
| [`star-wars-explorer`](star-wars-explorer/) | Larger app: dynamic segments, loaders, `errorElement`, MUI Material/Charts/DataGrid integration |
| [`shiny.fluent`](shiny.fluent/) | Multi-page `rhino` + `shiny.fluent` dashboard (see folder README) |

## Routers

| Example | What it shows |
|---|---|
| [`RouterProvider`](RouterProvider/) | The recommended entry point |
| [`createHashRouter`](createHashRouter/) | Hash-based data router (default choice) |
| [`createMemoryRouter`](createMemoryRouter/) | In-memory data router (wizards, embedded widgets) |
| [`MemoryRouter`](MemoryRouter/) | Legacy component-based memory router |

## Routes & navigation

| Example | What it shows |
|---|---|
| [`dynamic-segment`](dynamic-segment/) | Minimal `Route(path = ":id")` + `useParams()` |
| [`useNavigate`](useNavigate/) | Programmatic navigation |
| [`useNavigation`](useNavigation/) | Reading navigation state |
| [`useLocation`](useLocation/) | Reading the current location |
| [`useParams`](useParams/) | Reading route parameters |
| [`useSearchParams`](useSearchParams/) / [`setSearchParams`](setSearchParams/) | Reading and updating search params |
| [`useOutlet`](useOutlet/) / [`useOutletContext`](useOutletContext/) | Outlet inspection and parent → child context |
| [`useLinkClickHandler`](useLinkClickHandler/) | Custom link components |
| [`useViewTransitionState`](useViewTransitionState/) | View transitions |
| [`useRoutes`](useRoutes/) | Routes-as-data (legacy `Routes()` API) |
| [`useInRouterContext`](useInRouterContext/) | Detect whether you are inside a router |
| [`ScrollRestoration`](ScrollRestoration/) | Restore scroll position on navigation |

## Data loading & actions

| Example | What it shows |
|---|---|
| [`useLoaderData`](useLoaderData/) | The basic `loader` + `useLoaderData()` pattern |
| [`useLoaderData-api`](useLoaderData-api/) | Loader fetching from a remote API |
| [`Form`](Form/) | `Form()` GET + loader, POST + action with `useActionData()` |
| [`useFetcher`](useFetcher/) / [`useFetchers`](useFetchers/) | Background fetches without navigation |
| [`useSubmit`](useSubmit/) | Programmatic form submission |
| [`useRevalidator`](useRevalidator/) | Re-run the current loader on demand |
| [`shouldRevalidate`](shouldRevalidate/) | Skip loader re-runs when data is unchanged |
| [`Await`](Await/) / [`useAsyncValue`](useAsyncValue/) / [`useAsyncError`](useAsyncError/) | Deferred / streaming loader data |
| [`useBlocker`](useBlocker/) | Intercept navigation (e.g. unsaved-changes prompt) |

## Loader/action helpers

| Example | What it shows |
|---|---|
| [`redirect`](redirect/) | `redirect()` from a loader |
| [`redirectDocument`](redirectDocument/) | Full-document redirect |
| [`replaceResponse`](replaceResponse/) | Replace history entry from a loader |
| [`dataResponse`](dataResponse/) | Loader returning a typed `Response` |
| [`useRouteError`](useRouteError/) | Catching loader/action errors |

## Notes

- Most examples use the *data router* API (`createHashRouter()` +
  `RouterProvider()`), which supports `loader`, `action`, `useLoaderData()`,
  `useFetcher()`, etc. The [`MemoryRouter`](MemoryRouter/) example uses the
  older *component-style* API (`MemoryRouter()` + `Routes()` + `Route()`) —
  still supported in React Router v7, but new code should prefer the data
  router style.
- `RouterProvider()` examples render as static HTML and can also be embedded
  in Quarto / R Markdown documents — many use `htmltools::browsable()`
  rather than `shinyApp()`.
