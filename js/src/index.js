import * as Inputs from './inputs';
import * as RouterProvider from './routerProvider';
import * as Hooks from './hooks';

const ReactRouterLib = require('react-router-dom');

// Helpers reachable from user-authored JS() loader/action strings as
//   window.jsmodule['@/reactRouter'].helpers.redirect(...)
// Scoped under the existing `@/reactRouter` jsmodule namespace so the
// package never adds anything to the global `window` object.
const helpers = {
  redirect: ReactRouterLib.redirect,
  replace: ReactRouterLib.replace,
  redirectDocument: ReactRouterLib.redirectDocument,
  data: ReactRouterLib.data,
  // Path / URL utilities — the JS-side `path-to-regexp`-backed implementations
  // from react-router. Use these from inside JS() loader/action strings.
  generatePath: ReactRouterLib.generatePath,
  matchPath: ReactRouterLib.matchPath,
  matchRoutes: ReactRouterLib.matchRoutes,
  resolvePath: ReactRouterLib.resolvePath,
  parsePath: ReactRouterLib.parsePath,
  createPath: ReactRouterLib.createPath,
  createSearchParams: ReactRouterLib.createSearchParams,
  // Type guard for use inside an errorElement's render JS().
  isRouteErrorResponse: ReactRouterLib.isRouteErrorResponse,
};

window.jsmodule = {
  ...window.jsmodule,
  '@/reactRouter': { ...Inputs, ...RouterProvider, ...Hooks, helpers },
  'react-router-dom': ReactRouterLib,
};
