# NUST FRUITA

Online fruit shop that delivers to NUST hostel rooms and home addresses, with cash on delivery,
admin-defined delivery slots and a rider portal. Database Systems semester project.

The full specification is in [docs/SPEC.md](docs/SPEC.md). Decisions are in
[docs/DECISIONS.md](docs/DECISIONS.md) and progress in [docs/PROGRESS.md](docs/PROGRESS.md).

## Requirements

- Node.js 20 or newer
- MySQL 8.0.36 or newer, either installed locally or through `docker compose up -d db`

## First run

1. `npm install`
2. Copy `.env.example` to `.env` and fill in `DB_APP_PASSWORD`, `DB_MIGRATOR_PASSWORD` and `JWT_SECRET`.
   To generate a secret: `node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"`
3. Create the database accounts (once, using your MySQL root password):
   - PowerShell: `$env:MYSQL_ROOT_PASSWORD='your-root-password'; npm run db:create-users`
   - bash: `MYSQL_ROOT_PASSWORD=your-root-password npm run db:create-users`
4. `npm run dev`, then open http://localhost:5173

## Scripts

| Script                    | Does                                                          |
| ------------------------- | ------------------------------------------------------------- |
| `npm run dev`             | API on port 4000 + web app on port 5173                       |
| `npm test`                | Runs all test suites                                          |
| `npm run lint`            | ESLint                                                        |
| `npm run format`          | Prettier                                                      |
| `npm run build`           | Builds `web/dist`                                             |
| `npm run db:create-users` | Creates the `fruita_app` and `fruita_migrator` MySQL accounts |

Database scripts (`db:migrate`, `db:seed`, `db:reset`) arrive in Phase 1.

## Folder structure

```
db/        migrations, seed data and database scripts
shared/    zod schemas and constants used by both server and web
server/    Express REST API
web/       React single-page app (Vite + Tailwind)
docs/      specification, decisions, progress
```
