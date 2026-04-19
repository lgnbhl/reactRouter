import React from 'react';
import * as ReactRouter from 'react-router-dom';
import { ButtonAdapter } from '@/shiny.react';

// When a hook value is used as React children, objects/arrays must be stringified
// to avoid React error #31 ("Objects are not valid as a React child").
function safeAs(as, value) {
  if (as === 'children' && value != null && typeof value === 'object') {
    return JSON.stringify(value, null, 2);
  }
  return value;
}

// Resolve a dotted path like "summary.title" into nested object access.
function getPath(obj, path) {
  if (!path || obj == null) return obj;
  return path.split('.').reduce((acc, key) => acc?.[key], obj);
}

export const Link = ButtonAdapter(ReactRouter.Link);
export const NavLink = ButtonAdapter(ReactRouter.NavLink);

export function CreateHashRouter({ children, ...props }) {
  const router = React.useMemo(() => {
    const routes = ReactRouter.createRoutesFromElements(children);
    return ReactRouter.createHashRouter(routes, props);
  }, []);
  return React.createElement(ReactRouter.RouterProvider, { router });
}

export function CreateBrowserRouter({ children, ...props }) {
  const router = React.useMemo(() => {
    const routes = ReactRouter.createRoutesFromElements(children);
    return ReactRouter.createBrowserRouter(routes, props);
  }, []);
  return React.createElement(ReactRouter.RouterProvider, { router });
}

export function CreateMemoryRouter({ children, ...props }) {
  const router = React.useMemo(() => {
    const routes = ReactRouter.createRoutesFromElements(children);
    return ReactRouter.createMemoryRouter(routes, props);
  }, []);
  return React.createElement(ReactRouter.RouterProvider, { router });
}

export function useLoaderData({ selector, as, into, ...rest }) {
  const data = ReactRouter.useLoaderData();
  const value = selector ? getPath(data, selector) : data;
  return React.cloneElement(into, { [as]: safeAs(as, value), ...rest });
}

export function useActionData({ selector, as, into, ...rest }) {
  const data = ReactRouter.useActionData();
  const value = selector ? getPath(data, selector) : data;
  return React.cloneElement(into, { [as]: safeAs(as, value), ...rest });
}

export function useLocation({ selector, as, into, ...rest }) {
  const location = ReactRouter.useLocation();
  const value = selector ? getPath(location, selector) : location;
  return React.cloneElement(into, { [as]: safeAs(as, value), ...rest });
}

export function useParams({ selector, as, into, ...rest }) {
  const params = ReactRouter.useParams();
  const value = selector ? getPath(params, selector) : params;
  return React.cloneElement(into, { [as]: safeAs(as, value), ...rest });
}

export function useNavigation({ selector, as, into, ...rest }) {
  const navigation = ReactRouter.useNavigation();
  const value = selector ? getPath(navigation, selector) : navigation;
  return React.cloneElement(into, { [as]: safeAs(as, value), ...rest });
}

export function useRouteLoaderData({ routeId, selector, as, into, ...rest }) {
  const data = ReactRouter.useRouteLoaderData(routeId);
  const value = selector ? getPath(data, selector) : data;
  return React.cloneElement(into, { [as]: safeAs(as, value), ...rest });
}

export function useRouteError({ selector, as, into, ...rest }) {
  const error = ReactRouter.useRouteError();
  if (!error) return null;
  const value = selector ? (typeof error === 'object' ? getPath(error, selector) : error) : error;
  return React.cloneElement(into, { [as]: safeAs(as, value), ...rest });
}

export function useNavigationType({ as, into, ...rest }) {
  const navType = ReactRouter.useNavigationType();
  return React.cloneElement(into, { [as]: navType, ...rest });
}

export function useMatch({ pattern, selector, as, into, ...rest }) {
  const match = ReactRouter.useMatch(pattern || '/');
  if (!match) return null;
  const value = selector ? getPath(match, selector) : match;
  return React.cloneElement(into, { [as]: safeAs(as, value), ...rest });
}

export function useMatches({ selector, as, into, ...rest }) {
  const matches = ReactRouter.useMatches();
  const value = selector ? matches.map(m => getPath(m, selector)) : matches;
  return React.cloneElement(into, { [as]: safeAs(as, value), ...rest });
}

export function useSearchParams({ param, as, into, ...rest }) {
  const [searchParams] = ReactRouter.useSearchParams();
  let value;
  if (param) {
    value = searchParams.get(param) ?? '';
  } else {
    value = {};
    searchParams.forEach((v, key) => { value[key] = v; });
  }
  return React.cloneElement(into, { [as]: safeAs(as, value), ...rest });
}

export function useHref({ to, as, into, ...rest }) {
  const href = ReactRouter.useHref(to || '.');
  return React.cloneElement(into, { [as]: href, ...rest });
}

export function useResolvedPath({ to, selector, as, into, ...rest }) {
  const path = ReactRouter.useResolvedPath(to || '.');
  const value = selector ? getPath(path, selector) : path;
  return React.cloneElement(into, { [as]: safeAs(as, value), ...rest });
}

export function useFetcher({ selector, as, into, fetcherKey, ...rest }) {
  const fetcher = ReactRouter.useFetcher(fetcherKey ? { key: fetcherKey } : undefined);
  const value = selector ? getPath(fetcher, selector) : fetcher.state;
  return React.cloneElement(into, { [as]: safeAs(as, value), ...rest });
}

export function useFetchers({ selector, as, into, ...rest }) {
  const fetchers = ReactRouter.useFetchers();
  const value = selector ? fetchers.map(f => getPath(f, selector)) : fetchers;
  return React.cloneElement(into, { [as]: safeAs(as, value), ...rest });
}

export function useRevalidator({ selector, as, into, ...rest }) {
  const revalidator = ReactRouter.useRevalidator();
  const value = selector ? getPath(revalidator, selector) : revalidator.state;
  return React.cloneElement(into, { [as]: safeAs(as, value), ...rest });
}

export function useBlocker({ shouldBlock, selector, as, into, ...rest }) {
  const blocker = ReactRouter.useBlocker(shouldBlock ?? false);
  const value = selector ? getPath(blocker, selector) : blocker.state;
  return React.cloneElement(into, { [as]: safeAs(as, value), ...rest });
}

export function useOutletContext({ selector, as, into, ...rest }) {
  const context = ReactRouter.useOutletContext();
  const value = selector ? getPath(context, selector) : context;
  return React.cloneElement(into, { [as]: safeAs(as, value), ...rest });
}


// FetcherForm — a <form> bound to a fetcher instance.
// Use alongside useFetcher(fetcherKey = "...") to observe state/data.
export function FetcherForm({ fetcherKey, children, ...props }) {
  const fetcher = ReactRouter.useFetcher(fetcherKey ? { key: fetcherKey } : undefined);
  return React.createElement(fetcher.Form, props, children);
}

// RevalidatorButton — calls revalidator.revalidate() on click.
// If `into` is provided, injects onClick + disabled into that element (hook-wrapper style).
// Otherwise renders a plain <button>. Automatically disabled while revalidation is in progress.
export function RevalidatorButton({ into, children, style, disabled, ...props }) {
  const revalidator = ReactRouter.useRevalidator();
  const isLoading = revalidator.state !== 'idle';
  if (into) {
    return React.cloneElement(into, {
      onClick: () => revalidator.revalidate(),
      disabled: disabled || isLoading,
      ...props,
    });
  }
  return React.createElement(
    'button',
    {
      ...props,
      style,
      disabled: disabled || isLoading,
      onClick: () => revalidator.revalidate(),
    },
    children
  );
}

// RouterProvider — unified entry point: select type = "hash" | "browser" | "memory"
export function RouterProvider({ type, fallbackElement, children, ...props }) {
  const routerType = type || 'hash';
  const router = React.useMemo(() => {
    const routes = ReactRouter.createRoutesFromElements(children);
    if (routerType === 'browser') return ReactRouter.createBrowserRouter(routes, props);
    if (routerType === 'memory') return ReactRouter.createMemoryRouter(routes, props);
    return ReactRouter.createHashRouter(routes, props);
  }, [children]);
  return React.createElement(ReactRouter.RouterProvider, { router, fallbackElement });
}

// Await — renders into `into` when a deferred loader key resolves.
// Automatically wraps in <Suspense> (required by React Router's Await).
export function Await({ resolveKey, errorElement, fallback, as = 'children', into, selector, ...rest }) {
  const data = ReactRouter.useLoaderData();
  const deferred = data?.[resolveKey];
  const awaitEl = React.createElement(
    ReactRouter.Await,
    { resolve: deferred, errorElement },
    (value) => {
      const extracted = selector ? getPath(value, selector) : value;
      return React.cloneElement(into, { [as]: safeAs(as, extracted), ...rest });
    }
  );
  return React.createElement(
    React.Suspense,
    { fallback: fallback || React.createElement('span', null, 'Loading\u2026') },
    awaitEl
  );
}
