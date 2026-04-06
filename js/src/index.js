import * as Inputs from './inputs';

const ReactRouterDom = require('react-router-dom');

window.jsmodule = {
  ...window.jsmodule,
  '@/reactRouter': { ...Inputs },
  'react-router-dom': ReactRouterDom,
};

// Expose as a global so loader/action functions written via JS() can use
// ReactRouter utilities such as defer(), redirect(), and json().
window.ReactRouterDom = ReactRouterDom;
