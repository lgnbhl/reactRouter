import * as Inputs from './inputs';

window.jsmodule = {
  ...window.jsmodule,
  '@/shinyReactRouter': { ...Inputs },
  'react-router-dom': require('react-router-dom'),
};
