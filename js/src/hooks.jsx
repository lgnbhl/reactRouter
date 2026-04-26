import React from 'react';
import * as ReactRouter from 'react-router-dom';

// Resolve a dotted path like "summary.title" into nested object access.
function getPath(obj, path) {
  if (!path || obj == null) return obj;
  return path.split('.').reduce((acc, key) => acc?.[key], obj);
}

// Apply an optional `selector` (dotted path) to the raw hook result.
// With `mapArray`, the selector is applied to each element.
function applySelector(result, selector, mapArray) {
  if (mapArray) return selector ? result.map(m => getPath(m, selector)) : result;
  if (selector && typeof result === 'object') return getPath(result, selector);
  return result;
}

// Either call the user's JS render function with the raw hook result,
// or clone `into` and inject the selector-extracted value as the `as`
// prop. `selector` is intentionally ignored on the render-prop path —
// render receives the full hook value so it can navigate it freely
// (matches React Router's native render-prop mental model).
//
// When `as === "children"` and the value is a plain object, it is
// JSON-stringified to avoid React error #31 ("Objects are not valid as
// a React child"). Arrays of primitives (strings/numbers) are joined
// with ", " so repeated query params or list-like loader data display
// readably; arrays of objects still fall back to JSON.
function injectValue({ result, selector, mapArray, render, into, as, rest }) {
  if (typeof render === 'function') return render(result);
  let value = applySelector(result, selector, mapArray);
  if (as === 'children' && value != null && typeof value === 'object') {
    const isPrimitiveArray = Array.isArray(value) &&
      value.every(v => typeof v === 'string' || typeof v === 'number');
    value = isPrimitiveArray ? value.join(', ') : JSON.stringify(value, null, 2);
  }
  return React.cloneElement(into, { [as]: value, ...rest });
}

// Generic dispatcher for any React Router hook that fits the common shape:
//   value = ReactRouter[hook](hookArg?); optional dotted-path `selector`;
//   render it via `render` JS function or by cloning `into` with `[as]=value`.
//
// The R wrapper for each hook passes a fixed `hook` string, so the same hook
// is always invoked at the same position in the render tree — rules-of-hooks
// compliant. Hooks with distinct argument or return shapes (useSearchParams,
// useFetcher, Await) stay as dedicated components below.
export function UseHook({
  hook, hookArg, selector, as, into, render,
  mapArray = false, nullIfFalsy = false, ...rest
}) {
  const fn = ReactRouter[hook];
  if (typeof fn !== 'function') {
    throw new Error(
      `${hook}(): react-router-dom has no hook named "${hook}". ` +
      `This is an internal reactRouter package error — please report it.`
    );
  }
  const result = hookArg !== undefined ? fn(hookArg) : fn();
  if (nullIfFalsy && !result) return null;
  return injectValue({ result, selector, mapArray, render, into, as, rest });
}

// Not routed through UseHook: the hook returns a tuple [searchParams, setter]
// and `searchParams` is a URLSearchParams instance (not a plain object), so
// the generic dotted-path `selector` can't walk it. We use `.getAll(param)`
// so repeated keys like `?tag=a&tag=b` are preserved; single-value keys
// come back as a length-1 array, which R's vector semantics treat the same
// as a scalar, and `injectValue` renders arrays of primitives readably.
export function useSearchParams({ param, as, into, render, ...rest }) {
  const [searchParams, setSearchParams] = ReactRouter.useSearchParams();
  let result;
  if (param) {
    result = searchParams.getAll(param);
  } else {
    result = {};
    for (const key of new Set(searchParams.keys())) {
      result[key] = searchParams.getAll(key);
    }
  }
  // When using the render prop, pass the setter as a second argument so JS
  // code can update query params programmatically:
  //   render = JS("(val, setParams) => <button onClick={() => setParams({tag:'b'})}>...")
  if (typeof render === 'function') return render(result, setSearchParams);
  return injectValue({ result, render, into, as, rest });
}

// Not routed through UseHook: the hook takes an options object `{ key }`,
// not a positional arg, and passing `{ key: undefined }` is not equivalent
// to passing nothing. UseHook's `hookArg` is a single positional value and
// can't express this conditional wrapping.
export function useFetcher({ selector, as, into, render, fetcherKey, ...rest }) {
  const fetcher = ReactRouter.useFetcher(fetcherKey ? { key: fetcherKey } : undefined);
  return injectValue({ result: fetcher, selector, render, into, as, rest });
}

// Await — renders `into` (or calls `render`) when a deferred loader key
// resolves. Automatically wraps in <Suspense> (required by React Router's Await).
//
// Not routed through UseHook: this isn't a simple hook-value injection. It
// (1) calls useLoaderData() under a different public name, (2) looks up a
// `resolveKey` inside that data, (3) builds a <ReactRouter.Await> with a
// function-as-child, and (4) wraps the result in <Suspense> with a fallback.
// None of that fits the generic dispatcher's shape.
export function Await({ resolveKey, errorElement, fallback, as = 'children', into, selector, render, ...rest }) {
  const data = ReactRouter.useLoaderData();
  if (!data || !(resolveKey in data)) {
    throw new Error(
      `Await(): resolveKey "${resolveKey}" not found in loader data. ` +
      `Make sure the parent Route's loader returns an object with a "${resolveKey}" key ` +
      `holding a promise, e.g. () => ({ ${resolveKey}: fetch(...) }).`
    );
  }
  const awaitEl = React.createElement(
    ReactRouter.Await,
    { resolve: data[resolveKey], errorElement },
    (value) => injectValue({ result: value, selector, render, into, as, rest })
  );
  return React.createElement(
    React.Suspense,
    { fallback: fallback || React.createElement('span', null, 'Loading…') },
    awaitEl
  );
}
