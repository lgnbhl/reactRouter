import React from 'react';
import * as ReactRouter from 'react-router-dom';

// createHashRouter / createBrowserRouter / createMemoryRouter are "spec"
// components: they mirror the v7 factory functions but are only meaningful
// as the `router` prop of RouterProvider — never rendered on their own.
// Each one is a placeholder component whose *component type* carries a
// `__routerKind` marker that RouterProvider reads to pick the real factory.
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

// Map from the `__routerKind` marker to the real React Router v7 factory.
const ROUTER_FACTORIES = {
  hash: ReactRouter.createHashRouter,
  browser: ReactRouter.createBrowserRouter,
  memory: ReactRouter.createMemoryRouter,
};

// RouterProvider — mirrors the React Router v7 API:
//   <RouterProvider router={createHashRouter(routes)} fallbackElement={...} />
export function RouterProvider({ router, fallbackElement }) {
  const kind = router && router.type && router.type.__routerKind;
  if (!kind) {
    const got = router == null
      ? String(router)
      : (typeof router.type === 'function' ? router.type.name : typeof router);
    throw new Error(
      `RouterProvider: \`router\` must be createHashRouter(), createBrowserRouter(), ` +
      `or createMemoryRouter(). Got: ${got}.`
    );
  }
  const { children, ...opts } = router.props || {};
  if (children == null || (Array.isArray(children) && children.length === 0)) {
    throw new Error(
      `RouterProvider: the router has no routes. ` +
      `Pass one or more Route() elements, e.g. createHashRouter(Route(path = "/", element = ...)).`
    );
  }
  // Deps intentionally empty: the router owns its own navigation state and
  // must be created once. Re-creating on every render would reset the URL.
  // eslint-disable-next-line react-hooks/exhaustive-deps
  const rrRouter = React.useMemo(() => {
    const routes = ReactRouter.createRoutesFromElements(children);
    return ROUTER_FACTORIES[kind](routes, opts);
  }, []);
  // Warn (once) in dev if the *shape* of the route tree changes between
  // renders. Identity comparison would false-positive on every parent
  // re-render (Shiny re-renders frequently and `children` is a fresh array
  // each time even when its contents are unchanged); a structural signature
  // over the top-level Route props (path / index / id) only fires when the
  // user actually edits the route tree. Mirrors the original intent: catch
  // "I added a Route and it didn't appear" without crying wolf.
  const initialSig = React.useRef(routeSignature(children));
  const warned = React.useRef(false);
  if (
    !warned.current &&
    typeof process !== 'undefined' &&
    process.env &&
    process.env.NODE_ENV !== 'production' &&
    initialSig.current !== routeSignature(children)
  ) {
    warned.current = true;
    // eslint-disable-next-line no-console
    console.warn(
      'RouterProvider: `router` children changed after mount. The router ' +
      'is created once on mount and subsequent Route() changes are ignored. ' +
      'Remount RouterProvider (e.g. with a `key` prop) to apply new routes.'
    );
  }
  return React.createElement(ReactRouter.RouterProvider, { router: rrRouter, fallbackElement });
}

// Stable signature of a Route tree, used by the dev-only "children changed"
// warning. Only inspects the props that affect routing (path/index/id) and
// recurses into nested Route children. Children that aren't Route elements
// are summarised by their tag name only — their internal contents change on
// every render and shouldn't trip the warning.
function routeSignature(children) {
  const parts = [];
  React.Children.forEach(children, (child) => {
    if (!React.isValidElement(child)) {
      parts.push('_');
      return;
    }
    const { path, index, id, children: kids } = child.props || {};
    parts.push(
      [
        typeof child.type === 'string' ? child.type : (child.type && child.type.name) || '?',
        path || '',
        index ? '#' : '',
        id || '',
        kids ? `[${routeSignature(kids)}]` : '',
      ].join(':')
    );
  });
  return parts.join('|');
}
