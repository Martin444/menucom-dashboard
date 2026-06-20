---
tags:
  - index
  - repo/dashboard
aliases:
  - Dashboard Docs
  - Flutter Web Dashboard
---
# 🖥️ Dashboard — Flutter Web

Documentación del dashboard de gestión.

## Archivos

| Archivo | Descripción |
|---------|-------------|
| [[repo-dashboard/auth-architecture.md\|Auth Architecture]] | Secure storage, middleware, FCM sync |
| [[repo-dashboard/google-signin-setup.md\|Google Sign-In Setup]] | Configuración OAuth |
| [[repo-dashboard/edit-profile.md\|Edit Profile]] | Controlador y página de perfil |
| [[repo-dashboard/BUSINESS_SELECTION_IMPLEMENTATION.md\|Business Selection]] | UI de selección de tipo de negocio |
| [[repo-dashboard/CUSTOMER_VIEW_IMPLEMENTATION_CONFIRMED.md\|Customer View]] | Commerce cards |
| [[repo-dashboard/UI_IMPROVEMENTS_SUMMARY.md\|UI Improvements]] | Mejoras en commerce cards |
| [[repo-dashboard/STORE_URL_INTEGRATION_README.md\|Store URL Integration]] | Botón de URL en BusinessCard |
| [[repo-dashboard/OVERFLOW_FIX_SUMMARY.md\|Overflow Fix]] | Fix de RenderFlex overflow |
| [[repo-dashboard/NAVIGATION_IMPROVEMENTS.md\|Navigation]] | Refactor de sidebar |
| [[repo-dashboard/FLUENT_ICONS_MAPPING.md\|Fluent Icons]] | Migración Material→FluentUI |
| [[repo-dashboard/MIGRATION_CATALOGS.md\|Migration Catalogs]] | Wardrobe/Menu→Catalogs |
| [[repo-dashboard/ORDERS_IMPLEMENTATION.md\|Orders Implementation]] | Sistema de órdenes |
| [[repo-dashboard/orders-table-documentation.md\|Orders Table]] | Componente de tabla |
| [[repo-dashboard/EVENT-ORGANIZER-SALES-FLOW.md\|Event Organizer Sales]] | Flujo de ventas de eventos |
| [[repo-dashboard/events-code-review-and-ui-plan.md\|Events Code Review]] | Code review + UI plan |
| [[repo-dashboard/MP_OAUTH_IMPLEMENTATION_SUMMARY.md\|MP OAuth]] | MercadoPago OAuth |
| [[repo-dashboard/admin-billing-ui.md\|Admin Billing UI]] | UI de facturación admin |
| [[repo-dashboard/FIREBASE_SETUP.md\|Firebase Setup]] | Configuración Firebase |
| [[repo-dashboard/NETLIFY_VSCODE_SYNC.md\|Netlify Sync]] | Deploy Netlify + VS Code |
| `implementation/FCM-INTEGRATION.md` | FCM token sync |
| `implementation/ROADMAP-MOBILE-STOCK.md` | Mobile stock app roadmap |

## Conexiones clave

- [[maps/Auth & Roles]] → `auth-architecture`, `google-signin-setup`, `FIREBASE_SETUP`
- [[maps/Orders & Payments]] → `ORDERS_IMPLEMENTATION`, `orders-table`, `MP_OAUTH`
- [[maps/Events & Tickets]] → `EVENT-ORGANIZER-SALES-FLOW`, `events-code-review`
- [[maps/Monetization & Membership]] → `admin-billing-ui`
- [[maps/Commerce Domain]] → `BUSINESS_SELECTION`, `CUSTOMER_VIEW`, `STORE_URL`
- [[maps/Design System]] → `FLUENT_ICONS_MAPPING`, `UI_IMPROVEMENTS`, `NAVIGATION`, `OVERFLOW_FIX`
