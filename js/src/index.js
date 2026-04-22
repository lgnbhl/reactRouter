import * as Inputs from './inputs';
import * as RouterProvider from './routerProvider';
import * as Hooks from './hooks';

window.jsmodule = {
  ...window.jsmodule,
  '@/reactRouter': { ...Inputs, ...RouterProvider, ...Hooks },
  'react-router-dom': require('react-router-dom'),
};
