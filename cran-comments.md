## Submission

This is a major release that updates the package to React Router v7 and
adds the data router API (loaders, actions, fetchers), nested routes,
deferred data via `Await`, and the full set of v7 navigation hooks.

## Test environments

* local Windows 11, R release
* GitHub Actions:
  * windows-latest (R release)
  * macOS-latest (R release)
  * ubuntu-latest (R release, devel, oldrel-1)

## R CMD check results

0 errors | 0 warnings | 0 note

## Bundled JavaScript

The package ships a webpack-built bundle of `react-router-dom` at
`inst/reactRouter/react-router-dom.js`. Its license file is included
alongside it at `inst/reactRouter/react-router-dom.js.LICENSE.txt` (MIT,
compatible with the package license).

The buildable source for the bundle lives in `js/` (entry point
`js/src/index.js`, `webpack.config.js`, `package.json`). React and
ReactDOM are externalised at build time (see `webpack.config.js`) and
provided by the host `shiny.react` package, so `react-router-dom` is the
only third-party JavaScript shipped inside the bundle. The bundle can
be rebuilt with `cd js && yarn install && yarn build`.

## Reverse dependencies

There are no reverse dependencies on CRAN.
