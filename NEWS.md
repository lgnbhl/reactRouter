# reactRouter 0.3.0

## New features

* `useSearchParams()` gains a `single` argument. When `TRUE`, it uses
  `URLSearchParams.get()` instead of `getAll()`, returning the first value
  as a scalar string (or `null` if absent) instead of an array. This lets
  `into`/`as` target props that need a scalar, such as MUI `Tabs` or
  `Select` `value`. The default (`FALSE`) keeps the previous behaviour.
* `useSearchParams()` gains a `defaultInit` argument, forwarded to the
  hook's native `defaultInit`: default values used for keys missing from
  the URL (e.g. `defaultInit = list(tab = "overview")`). They are not
  written into the URL.
* `useHref()` and `useResolvedPath()` gain a `relative` argument
  (`"route"` or `"path"`), forwarded as the hooks' `{ relative }` option.
  It controls whether `..` goes up one route level or one URL segment.
* New `useBeforeUnload()` wraps the hook of the same name: it runs a `JS()`
  callback when the tab is closed or reloaded, complementing `useBlocker()`
  for in-app navigation.
* New `useFormAction()` wraps the hook of the same name: it injects the URL
  a `Form` in the current route would submit to (optionally for a given
  `action` path and `relative` mode), for building custom forms.

## Minor changes

* An argument named `single` passed to `useSearchParams()` is no longer
  forwarded to the `into` component as a prop.

# reactRouter 0.2.1

Dependency maintenance release. No changes to the R API.

* Updated the bundled `react-router-dom` from 7.15.0 to 7.18.2 and rebuilt
  `inst/reactRouter/react-router-dom.js`.
* Updated the JavaScript build toolchain: `webpack` 5.109.2 and
  `webpack-cli` 7.2.2.
* Updated GitHub Actions workflows: `actions/checkout` v7,
  `actions/setup-node` v7, and Node 24 for the JS build check.

# reactRouter 0.2.0

CRAN submission. Major release upgrading the package to React Router v7
with the data router API (loaders, actions, fetchers, deferred data).

## Breaking changes

- `RouterProvider()` now takes a `router` argument built with
  `create*Router()` instead of route children.
- `data()` was renamed to `dataResponse()` and `replace()` was renamed to
  `replaceResponse()` to avoid masking base R functions.
- `reloadDocument` on `Link()` / `NavLink()` defaults to `FALSE`.

## New features

- Updated to React Router v7 (`react-router-dom` 7.x).
- Data router API: `createBrowserRouter()`, `createHashRouter()`,
  `createMemoryRouter()` paired with `RouterProvider(router = ...)` —
  the recommended way to use loaders, actions, fetchers, and `Await`.
- New components: `Await`, `Form`, `ScrollRestoration`, `Outlet`, `Routes`,
  `Navigate`.
- New hooks: `useLoaderData`, `useActionData`, `useNavigation`,
  `useNavigate`, `useNavigationType`, `useMatch`, `useMatches`,
  `useSearchParams`, `useRouteError`, `useRouteLoaderData`, `useFetcher`,
  `useFetchers`, `useRevalidator`, `useBlocker`, `useSubmit`, and more.
- New loader/action helpers: `redirect()`, `replaceResponse()`,
  `redirectDocument()`, `dataResponse()`.

## Security

- `redirect()`, `replaceResponse()`, and `redirectDocument()` reject unsafe
  URL schemes (`javascript:`, `data:`, `vbscript:`) and protocol-relative
  targets.
- `reactRouterExample()` validates `example` against the list of bundled
  examples, closing a path-traversal vector in user-supplied input.
- New vignette: "Security considerations" — guidance on loaders/actions as
  client-side code, URL-encoding route params, redirect targets, CSP, and more.

## Diagnostics & ergonomics

- `Route()` validates that `loader` and `action` inherit from `JS_EVAL` at
  call time, surfacing a common mistake before it becomes a browser-side error.
- `dataResponse()`: `value` is now a required argument.
- `useNavigate()`, `useSubmit()`, and `useLinkClickHandler()` refuse
  `into=` with `as = "children"` and point to `render = JS(...)` or
  `as = "onClick"` — these hooks return functions, not renderable children.
- `RouterProvider` logs a dev-mode warning when the route tree changes after
  mount; remount via a `key` prop to apply new routes.

# reactRouter 0.1.2

* BREAKING CHANGE: `reloadDocument` is now FALSE by default (like in React Router 6.30.0)
* added data loader and hooks
* improve examples and docs

# reactRouter 0.1.1

* fix #1
* add more examples

# reactRouter 0.1.0

* initial commit
