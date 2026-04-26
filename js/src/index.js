import * as Inputs from './inputs';
import * as RouterProvider from './routerProvider';
import * as Hooks from './hooks';

const ReactRouterLib = require('react-router-dom');

window.jsmodule = {
  ...window.jsmodule,
  '@/reactRouter': { ...Inputs, ...RouterProvider, ...Hooks },
  'react-router-dom': ReactRouterLib,
};

// Exposed so user-authored loader/action JS() strings can call these without
// needing to reach into window.jsmodule. Kept on a namespaced global to avoid
// colliding with anything in the host page.
window.reactRouterHelpers = {
  redirect: ReactRouterLib.redirect,
  replace: ReactRouterLib.replace,
  data: ReactRouterLib.data,
};
