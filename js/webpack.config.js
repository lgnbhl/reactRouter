const path = require('path');

// `mode: 'production'` already wires webpack's built-in DefinePlugin to set
// `process.env.NODE_ENV = 'production'`, so react-router's dev-only branches
// (and our own `process.env.NODE_ENV !== 'production'` guards) get
// dead-code-eliminated by the minifier. No explicit DefinePlugin needed.
const config = {
  entry: './src/index.js',
  mode: 'production',
  output: {
    path: path.join(__dirname, '..', 'inst', 'reactRouter'),
    filename: 'react-router-dom.js',
  },
  resolve: { extensions: ['.js', '.jsx', '.ts', '.tsx'] },
  externals: {
    react: 'jsmodule["react"]',
    'react-dom': 'jsmodule["react-dom"]',
    '@/shiny.react': 'jsmodule["@/shiny.react"]',
  },
  performance: {
    maxAssetSize: 2097152, // 2 MiB
    maxEntrypointSize: 2097152, // 2 MiB
  },
};

module.exports = config;
