const webpack = require('webpack');
const path = require('path');

const config = {
  entry: './src/index.js',
  mode: 'production',
  output: {
    path: path.join(__dirname, '..', 'inst', 'shinyReactRouter-6.30.0'),
    filename: 'react-router-dom.js',
  },
  resolve: { extensions: ['.js', '.jsx', '.ts', '.tsx'] },

  externals: {
    react: 'jsmodule["react"]',
    'react-dom': 'jsmodule["react-dom"]',
    '@/shiny.react': 'jsmodule["@/shiny.react"]',
  },
  plugins: [new webpack.DefinePlugin({ 'process.env': '{}' })],
};

module.exports = config;
