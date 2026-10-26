# Changelog

## Unreleased

- Security: columns holding secrets no longer show up in the studio. The
  delete page's record summary and the default list view (no
  `listDisplay`) skip `passwordFields`, and `register()` now accepts
  `passwordFields`. When it isn't given, any column whose name contains
  `password`, `passwd` or `secret` counts as one; pass `const []` to opt
  out. Edit forms leave a password field blank and not required, and a
  blank submission keeps the stored value instead of overwriting it.
- UI: restyled on the IBM Carbon Design System (v11). Carbon colour tokens
  with the g10 theme, switching to g100 when the browser prefers dark mode;
  IBM Plex Sans/Mono; the Carbon UI shell (header plus side nav, which
  becomes a drawer below 1056px); Carbon data table with toolbar search,
  batch-action bar and pagination; Carbon text inputs with helper and error
  states; button sets; inline notifications; clickable tiles on the
  overview; a danger dialog for deletes; Carbon icons inlined as SVG. No
  route or form-field changes.

## 0.1.1

- Unified version with the rest of the gisila ecosystem (`gisila`, `gisila_doc`, `gisila_orm`).
- Updated `gisila_orm` dependency constraint to `^0.1.1`.
- Added `ModelAdmin` configuration: per-model control over `listDisplay`, `searchFields`, `readonlyFields`, `excludeFields`, and `ordering`; accepts both camelCase Dart names and snake_case column names interchangeably.
- Added `theme.dart`: dark CSS stylesheet with CSS variables, Google Fonts (Inter), and a polished sidebar/topbar layout.
- Bug fixes and UI refinements across list, form, detail, and dashboard pages.

## 0.1.0

- Initial release.
- Django-admin-style web UI auto-generated from `TableMeta` registrations.
- CRUD list, form, and detail pages served over Shelf.
- Built-in login page and session-based authentication.
- Themeable layout with dashboard overview.
