# Progress

One entry per phase (spec rule 8): what was built, what was tested, known issues.

## P0 — Setup (2026-11-24)

**Built**

- npm-workspaces monorepo: `shared`, `server`, `web`; ESLint (flat config), Prettier, `.editorconfig`, `.gitattributes` (LF endings).
- `.env.example` with every variable from spec 17.1; `server/src/config.js` stops at startup if one is missing.
- `db/scripts/create-users.js`: creates `fruita_app` (no DDL) and `fruita_migrator`, plus empty `fruita` and `fruita_test` databases.
- Express app with helmet, JSON body limit, cookie parser, morgan, `GET /api/health` → `{status:'ok', db:'ok'}`, JSON 404 and a central error handler.
- Vite + React + Tailwind (design tokens from 13.1); the home page shows "Hello FRUITA" and the health result through the `/api` proxy.
- Optional `docker-compose.yml` (MySQL 8.4 at +05:00).
- GitHub Actions: install, lint, format check, create DB users, test, build, against a MySQL 8.4 service.

**Tested**

- `server/test/health.test.js` (health ok, JSON 404).
- Lint, format check and web build run locally.
- CI green on PR #1 and on `main` after the merge.
- Verified on Umar's laptop (2026-11-28): `db:create-users` created both accounts and databases with the right grants, `npm test` 2/2 passed, the browser shows "Hello FRUITA · API: ok · Database: ok".

**Status:** P0 complete. Tehreem and Aimen invited to the repository; they set up their laptops by following the README.

**Known issues**

- None yet.
