import * as ReactRouter from 'react-router-dom';
import { ButtonAdapter } from '@/shiny.react';

export const Link = ButtonAdapter(ReactRouter.Link);
export const NavLink = ButtonAdapter(ReactRouter.NavLink);
export const Route = ButtonAdapter(ReactRouter.Route);
