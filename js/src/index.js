import * as Inputs from './inputs';

window.jsmodule = {
  ...window.jsmodule,
  '@/reactRouter': { ...Inputs },
  'react-router-dom': require('react-router-dom'),
};
