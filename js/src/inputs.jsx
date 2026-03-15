import React from 'react';
import * as ReactRouter from 'react-router-dom';
import { ButtonAdapter } from '@/shiny.react';

export const Link = ButtonAdapter(ReactRouter.Link);
export const NavLink = ButtonAdapter(ReactRouter.NavLink);

export function CreateHashRouter({ children, ...props }) {
  const router = React.useMemo(() => {
    const routes = ReactRouter.createRoutesFromElements(children);
    return ReactRouter.createHashRouter(routes, props);
  }, []);
  return React.createElement(ReactRouter.RouterProvider, { router });
}
