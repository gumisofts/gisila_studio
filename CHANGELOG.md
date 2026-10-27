# Changelog

## Unreleased

- Docs: the README no longer promises sortable column headers (lists use
  `ordering`) and describes the current login, CSRF and password-field
  behaviour.
- `register()` takes `onSave:`, per-column hooks that transform a submitted
  value before it is written (hash a password, normalise an email). A
  `FormatException` from a hook is shown on the field. Password columns
  without a hook log a startup warning, since they store what is typed.
- Security: every POST made with the studio cookie must carry the
  session's CSRF token (`_csrf`), which the studio adds to each of its POST
  forms; requests authenticated with a Bearer token are exempt. The token is
  derived from the session token (`studioCsrfToken`), so all isolates agree.
  Forms you render yourself under the studio need the field too.
- Security: sign-in is throttled per client address (10 failures in 15
  minutes → `429`, per isolate). Behind a proxy all clients share its
  address.
- Security: the auth cookie gets `Secure` when the request came over HTTPS
  (directly or per `X-Forwarded-Proto`). Credentials and JWT signatures are
  compared in constant time (`constantTimeEquals`).
- Forms: a value that doesn't parse (letters in a number field, a bad
  date) is now a field error (422) instead of being saved as NULL. A blank
  NOT NULL field uses the column's database default when it has one (on
  edit: keeps the stored value) and is otherwise "This field is required."
  for non-text columns; it used to be saved as `0`, `0.0` or the current
  time. Nullable fields still save NULL and an unchecked checkbox `false`.
- Lists: `page=0` or a negative page shows the first page (it was a 500
  from a negative OFFSET).
- Sidebar/overview counts: a table Postgres estimates at 100,000 rows or
  more shows the planner estimate (`pg_class.reltuples`) instead of a
  `COUNT(*)` scan on every page view; smaller tables stay exact.
- Tests: `test/column_info_test.dart`, and `test/studio_crud_test.dart`
  against Postgres on localhost:5454 (skipped when it isn't running).
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
