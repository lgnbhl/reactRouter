# reactRouter 0.2.0

- CRAN submission.
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
- New URL utilities (pure R): `generatePath()` and `matchPath()`.
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
