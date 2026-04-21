import React from 'react';
import * as ReactRouter from 'react-router-dom';
import { ButtonAdapter } from '@/shiny.react';

// When a hook value is used as React children, objects/arrays must be stringified
// to avoid React error #31 ("Objects are not valid as a React child").
function safeAs(as, value) {
  if (as === 'children' && value != null && typeof value === 'object') {
    return JSON.stringify(value, null, 2);
  }
  return value;
}

// Resolve a dotted path like "summary.title" into nested object access.
function getPath(obj, path) {
  if (!path || obj == null) return obj;
  return path.split('.').reduce((acc, key) => acc?.[key], obj);
}

// Apply an optional `selector` (dotted path) to the raw hook result. With
// `mapArray`, the selector is applied to each element.
function applySelector(result, selector, mapArray) {
  if (mapArray) {
    return selector ? result.map(m => getPath(m, selector)) : result;
  }
  if (selector) {
    return typeof result === 'object' ? getPath(result, selector) : result;
  }
  return result;
}

// Shared tail: either call the user's JS render function with the raw hook
// result, or clone `into` and inject the selector-extracted value as the
// `as` prop. `selector` is intentionally ignored on the render-prop path —
// render receives the full hook value so it can navigate it freely (matches
// React Router's native render-prop mental model).
function injectValue({ result, selector, mapArray, render, into, as, rest }) {
  if (typeof render === 'function') return render(result);
  const value = applySelector(result, selector, mapArray);
  return React.cloneElement(into, { [as]: safeAs(as, value), ...rest });
}

export const Link = ButtonAdapter(ReactRouter.Link);
export const NavLink = ButtonAdapter(ReactRouter.NavLink);

// createHashRouter / createBrowserRouter / createMemoryRouter are "spec"
// components: they mirror the v7 factory functions and are only meaningful
// as the `router` prop of RouterProvider — never rendered on their own.
function makeRouterSpec(kind, rName) {
  const Spec = function () {
    throw new Error(
      `${rName}() must be passed to RouterProvider(router = ${rName}(...)). ` +
      `It cannot be rendered on its own.`
    );
  };
  Spec.__routerKind = kind;
  return Spec;
}

export const CreateHashRouter = makeRouterSpec('hash', 'createHashRouter');
export const CreateBrowserRouter = makeRouterSpec('browser', 'createBrowserRouter');
export const CreateMemoryRouter = makeRouterSpec('memory', 'createMemoryRouter');

// Generic dispatcher for any React Router hook that fits the common shape:
//   value = ReactRouter[hook](hookArg?); optional dotted-path `selector`;
//   render it via `render` JS function or by cloning `into` with `[as]=value`.
//
// The R wrapper for each hook passes a fixed `hook` string, so the same hook
// is always invoked at the same position in the render tree — rules-of-hooks
// compliant. Hooks with distinct argument or return shapes (useSearchParams,
// useFetcher, Await) stay as dedicated components below.
export function UseHook({
  hook, hookArg, selector, as, into, render,
  mapArray = false, nullIfFalsy = false, ...rest
}) {
  const fn = ReactRouter[hook];
  if (typeof fn !== 'function') {
    throw new Error(`UseHook: react-router-dom has no hook "${hook}"`);
  }
  const result = hookArg !== undefined ? fn(hookArg) : fn();
  if (nullIfFalsy && !result) return null;
  return injectValue({ result, selector, mapArray, render, into, as, rest });
}

export function useSearchParams({ param, as, into, render, ...rest }) {
  const [searchParams] = ReactRouter.useSearchParams();
  let result;
  if (param) {
    result = searchParams.get(param) ?? '';
  } else {
    result = {};
    searchParams.forEach((v, key) => { result[key] = v; });
  }
  return injectValue({ result, render, into, as, rest });
}

export function useFetcher({ selector, as, into, render, fetcherKey, ...rest }) {
  const fetcher = ReactRouter.useFetcher(fetcherKey ? { key: fetcherKey } : undefined);
  return injectValue({ result: fetcher, selector, render, into, as, rest });
}

// RouterProvider — mirrors the React Router v7 API:
//   <RouterProvider router={createHashRouter(routes)} fallbackElement={...} />
export function RouterProvider({ router, fallbackElement }) {
  const kind = router && router.type && router.type.__routerKind;
  if (!kind) {
    throw new Error(
      'RouterProvider: `router` must be createHashRouter(), createBrowserRouter(), or createMemoryRouter().'
    );
  }
  const { children, ...opts } = router.props || {};
  const rrRouter = React.useMemo(() => {
    const routes = ReactRouter.createRoutesFromElements(children);
    if (kind === 'browser') return ReactRouter.createBrowserRouter(routes, opts);
    if (kind === 'memory') return ReactRouter.createMemoryRouter(routes, opts);
    return ReactRouter.createHashRouter(routes, opts);
  }, []);
  return React.createElement(ReactRouter.RouterProvider, { router: rrRouter, fallbackElement });
}

// Await — renders `into` (or calls `render`) when a deferred loader key
// resolves. Automatically wraps in <Suspense> (required by React Router's Await).
export function Await({ resolveKey, errorElement, fallback, as = 'children', into, selector, render, ...rest }) {
  const data = ReactRouter.useLoaderData();
  const deferred = data?.[resolveKey];
  const awaitEl = React.createElement(
    ReactRouter.Await,
    { resolve: deferred, errorElement },
    (value) => injectValue({ result: value, selector, render, into, as, rest })
  );
  return React.createElement(
    React.Suspense,
    { fallback: fallback || React.createElement('span', null, 'Loading\u2026') },
    awaitEl
  );
}
