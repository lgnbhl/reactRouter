# reactRouter 0.2.0

- CRAN submission.
- Security: `reactRouterExample()` now validates `example` against the list of
  bundled examples and rejects anything else, closing a path-traversal vector
  in user-supplied input.
- Security: `redirect()`, `replaceResponse()`, and `redirectDocument()` reject
  `javascript:`, `data:`, and `vbscript:` URL schemes in `to`, and now also
  reject protocol-relative targets like `//evil.example.com/path` (which the
  browser would treat as cross-origin). Use a full `https://...` URL if you
  genuinely need a cross-origin redirect.
- `Route()` now validates that `loader` and `action`, when non-NULL, inherit
  from `JS_EVAL` -- mirroring the diagnostic quality of the hook wrappers
  and surfacing a common mistake at call time instead of as a confusing
  browser-side error.
- `dataResponse()`: `value` is now a required argument (the previous
  `value = NULL` default rarely produced what users wanted).
- `RouterProvider` (JS): logs a one-shot dev-mode `console.warn` when the
  `router`'s children change between renders. The router is created once
  on mount and subsequent `Route()` changes are silently ignored;
  remount the provider (e.g. via a `key` prop) to apply new routes.
- `print.reactRouter()` falls back to plain `shiny.tag` printing if the
  htmltools render path fails (e.g. on a partial install where the bundled
  JS dependency is missing) instead of surfacing an opaque error.
- Security: the `UseHook` JSX dispatcher now restricts the dispatched hook
  name to a fixed allowlist, preventing arbitrary lookups against the
  `react-router-dom` namespace via crafted props.
- Security: moved `jsonlite` from `Suggests` to `Imports` so the JSON-safe
  escape path in `JS()` literal generation (control chars, U+2028/U+2029,
  `</script>`) is always taken; removed the partial fallback.
- Bumped bundled `react-router-dom` to 7.15.x and rebuilt the JS bundle.
- Internal: webpack now relies on `mode: 'production'` to set
  `process.env.NODE_ENV` (the explicit `DefinePlugin` was redundant and the
  previous `process.env = {}` form leaked the `RouterProvider`
  "children changed after mount" dev warning into production builds).
- `RouterProvider` (JS): the dev-mode "children changed after mount" warning
  now compares a structural signature of the route tree (path / index / id)
  rather than identity, so it no longer false-positives on every parent
  re-render.
- `Await` Suspense fallback: the default "Loading…" span now carries
  `role="status"` and `aria-live="polite"` so screen readers announce the
  loading state.
- `useNavigationType()`: documented the intentional absence of a `selector`
  argument (the upstream hook returns a scalar string).
- New `js/README.md` documents the bundle layout, build command, and
  conventions.
- Tests: added pure-R coverage for `redirect()` / `replaceResponse()` /
  `redirectDocument()` rejection paths (unsafe schemes, protocol-relative
  URLs, NA / multi-element `to`) and for `dataResponse(value = NULL)`.
- New vignette: "Security considerations" — guidance on loaders/actions as
  client-side code, URL-encoding route params, redirect targets, CSP, and
  more.
- The `star-wars-explorer` example wraps `params.id` in `encodeURIComponent`
  before splicing into a `fetch()` URL, modelling the safe pattern.
- Updated React Router to v7. The package now wraps `react-router-dom` 7.x.
- Adopted the v7 data router API: `createBrowserRouter()`, `createHashRouter()`,
  `createMemoryRouter()` paired with `RouterProvider(router = ...)`. This is the
  recommended way to use loaders, actions, fetchers, and `Await`.
- New components: `Await`, `Form`, `ScrollRestoration`, `Outlet`, `Routes`,
  `Navigate`.
- New navigation hooks: `useLoaderData`, `useActionData`, `useNavigation`,
  `useNavigate`, `useNavigationType`, `useMatch`, `useMatches`, `useSearchParams`,
  `useRouteError`, `useRouteLoaderData`, `useFetcher`, `useFetchers`,
  `useRevalidator`, `useBlocker`, `useHref`, `useResolvedPath`, `useSubmit`,
  `useAsyncValue`, `useAsyncError`, `useRoutes`, `useInRouterContext`,
  `useOutlet`, `useOutletContext`, `useViewTransitionState`, `useLinkClickHandler`.
- New loader/action helpers: `redirect()`, `replaceResponse()`,
  `redirectDocument()`, `dataResponse()`. The same helpers are exposed on
  `window.reactRouterHelpers` for use inside custom JS loaders.
- BREAKING CHANGE: `RouterProvider` now takes a `router` argument built with
  `create*Router()` instead of route children.
- BREAKING CHANGE: `reloadDocument` defaults to `FALSE` (mirroring React
  Router's own default).
- BREAKING CHANGE: `data()` was renamed to `dataResponse()` so it does not
  mask `base::data()`.
- BREAKING CHANGE: `replace()` was renamed to `replaceResponse()` so it does
  not mask `base::replace()`.
- Naming rule for loader/action helpers: upstream React Router names are
  preserved as-is, except where they would mask a base R function — in which
  case the helper takes a `*Response` suffix (`dataResponse`,
  `replaceResponse`). `redirect` and `redirectDocument` keep their original
  names because they do not collide.
- Internal: `randomKey()` no longer perturbs the user's RNG state.
- Internal: removed an unused `useFormAction` JS export and de-duplicated the
  R hook-element helpers.

# reactRouter 0.1.2

* BREAKING CHANGE: `reloadDocument` is now FALSE by default (like in React Router 6.30.0)
* added data loader and hooks
* improve examples and docs

# reactRouter 0.1.1

* fix #1
* add more examples

# reactRouter 0.1.0

* initial commit
