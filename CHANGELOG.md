# Changelog

## Unreleased

- Security (breaking): the studio no longer runs without a login. With no
  credentials, or weak ones (password under 12 characters, equal to the
  username or a placeholder; JWT signing secret under 32 characters), it
  serves a "Studio is disabled" page (503) and logs why to stderr; the rest
  of the app keeps running. Opt out with `allowUnauthenticated: true` (no
  login, dev only) or `allowInsecure: true` / `GISILA_ALLOW_INSECURE=1`
  (weak credentials, with a warning). `StudioAuth.weaknessReason()` lets
  custom strategies join in; `credentialWeakness` and `secretWeakness` are
  exported.
- Auth: the constructor takes `secret` (or `STUDIO_SECRET`); with it the
  username/password shorthand builds a `JwtStudioAuth`, which works across
  isolates, instead of the per-isolate `SessionStudioAuth`.
- Tests: first test suite (`test/studio_auth_test.dart`).
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
