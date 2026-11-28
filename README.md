# NUST FRUITA

Online fruit shop that delivers to NUST hostel rooms and home addresses, with cash on delivery,
admin-defined delivery slots and a rider portal that confirms delivery with a 4-digit code.
Database Systems semester project.

- Full specification: [docs/SPEC.pdf](docs/SPEC.pdf)
- Decisions where the spec was unclear: [docs/DECISIONS.md](docs/DECISIONS.md)
- What has been built so far: [docs/PROGRESS.md](docs/PROGRESS.md)

## Contents

1. [Team and division of work](#1-team-and-division-of-work)
2. [How the three of us share work](#2-how-the-three-of-us-share-work)
3. [Install the tools (once per laptop)](#3-install-the-tools-once-per-laptop)
4. [Get the project and set it up (once per laptop)](#4-get-the-project-and-set-it-up-once-per-laptop)
5. [Daily workflow](#5-daily-workflow)
6. [Team rules](#6-team-rules)
7. [Build phases and owners](#7-build-phases-and-owners)
8. [Scripts](#8-scripts)
9. [Folder structure](#9-folder-structure)
10. [Troubleshooting](#10-troubleshooting)

---

## 1. Team and division of work

The work is split by business area (spec section 16). Each person owns their area from end to
end: the tables, the triggers and procedures, the backend API and the pages. In the viva, each
person explains their own area line by line.

|                                 | Umar Hayat Ali                                                                                                                                                                          | Tehreem                                                                                                                      | Aimen                                                                              |
| ------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| **Area**                        | Orders and delivery                                                                                                                                                                     | Catalog and inventory                                                                                                        | Users, auth and cart                                                               |
| **Tables**                      | `delivery_slots`, `orders`, `order_items`, `payments`, `deliveries`, `order_status_history`                                                                                             | `categories`, `products`, `reviews`, `site_settings`                                                                         | `users`, `riders`, `hostels`, `addresses`, `carts`, `cart_items`, `wishlist_items` |
| **Triggers, procedures, views** | All 10 stored procedures, `trg_orders_ai/au`, `trg_order_items_bi`, views `v_available_slots`, `v_order_summary`, `v_delivered_orders`, `v_failed_needing_action`, `v_rider_deliveries` | `trg_products_bi/bu`, `trg_categories_bu`, `trg_reviews_bi`, views `v_product_ratings`, `v_low_stock`, `v_product_sales_30d` | `trg_riders_bi`, `trg_cart_items_bi/bu`                                            |
| **Backend modules**             | orders, rider, admin orders/slots/stats/alerts                                                                                                                                          | catalog, admin products/categories/settings, reviews                                                                         | auth, me, addresses, cart, wishlist, admin users/riders/hostels                    |
| **Pages**                       | checkout, my orders, rider portal, admin orders, slots, dashboard, statistics                                                                                                           | shop, product page, admin products, categories, settings, animated landing page                                              | login, register, profile, cart, wishlist, admin users, riders, hostels             |
| **Extra role**                  | Team lead: setup, CI, merging                                                                                                                                                           | Landing page (Phase 8)                                                                                                       | Shared UI components (`web/src/components/ui`)                                     |

**Shared by everyone:** `shared/` (validation rules and constants), and tests for your own area.

**Team status (2026-11-28):** all three members have access to the GitHub repository. Umar's laptop
is fully set up (Phase 0 verified). Tehreem and Aimen set up their laptops by following
[sections 3 and 4](#3-install-the-tools-once-per-laptop).

| Member         | GitHub access | Laptop setup (sections 3–4) |
| -------------- | ------------- | --------------------------- |
| Umar Hayat Ali | ✅ Owner      | ✅ Done                     |
| Tehreem        | ✅ Accepted   | In progress                 |
| Aimen          | ✅ Accepted   | In progress                 |

## 2. How the three of us share work

- **GitHub holds all the code**: frontend (`web/`), backend (`server/`) and database (`db/`).
- **The database is never copied between laptops.** Each person installs MySQL on their own
  laptop. The whole database (tables, triggers, procedures, views and demo data) is written as
  SQL files in `db/`. Running `npm run db:reset` builds exactly the same database on any laptop.
  (`db:reset` arrives in Phase 1.)
- **`.env` is private.** It holds your own passwords and is never uploaded. Each person creates
  their own.
- **Test orders you create while clicking around stay on your laptop.** Everyone gets the same
  demo data from the seed, so this does not matter.
- If your database gets broken, `npm run db:reset` wipes it and rebuilds it in seconds.

| Thing                         | How it reaches the others                    |
| ----------------------------- | -------------------------------------------- |
| Frontend and backend code     | `git push` / `git pull` through GitHub       |
| Database design and demo data | SQL files on GitHub, then `npm run db:reset` |
| MySQL itself                  | Each person installs it once                 |
| `.env` passwords              | Never shared                                 |

## 3. Install the tools (once per laptop)

You need: **Git**, **Node.js 20 or newer**, **MySQL 8**, **VS Code** and a **GitHub account**.

### Step 3.1: Check what you already have

Open **PowerShell** (press the Windows key, type `PowerShell`, press Enter) and run these one at
a time:

```powershell
git --version
node -v
npm -v
code --version
Get-Service *mysql*
```

| Command               | Good result                                    | If you see an error                                                               |
| --------------------- | ---------------------------------------------- | --------------------------------------------------------------------------------- |
| `git --version`       | `git version 2.x`                              | Install Git (step 3.2)                                                            |
| `node -v`             | `v20.x` or higher                              | Install Node.js (step 3.3). If it shows v18 or lower, install the new one over it |
| `npm -v`              | any version number                             | Comes with Node.js                                                                |
| `code --version`      | a version number                               | Install VS Code (step 3.4)                                                        |
| `Get-Service *mysql*` | a row with `Running` and a name like `MySQL80` | Install MySQL (step 3.5). If it shows `Stopped`, see Troubleshooting              |

Skip any step below for a tool you already have.

### Step 3.2: Install Git

1. Go to https://git-scm.com/download/win and download the installer.
2. Run it and click **Next** on every screen (the defaults are fine).
3. Close PowerShell, open a new one, and check: `git --version`
4. Tell Git your name and email (use the email of your GitHub account):

```powershell
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

### Step 3.3: Install Node.js

1. Go to https://nodejs.org and download the **LTS** version.
2. Run the installer and click **Next** on every screen.
3. Close PowerShell, open a new one, and check: `node -v`

### Step 3.4: Install VS Code

1. Go to https://code.visualstudio.com and download it.
2. During installation, tick **"Add to PATH"** and **"Add 'Open with Code' action"**.

### Step 3.5: Install MySQL

1. Go to https://dev.mysql.com/downloads/installer/ and download **MySQL Installer for Windows**
   (the larger file). On the next page click **"No thanks, just start my download"**.
2. Run it and choose **Server only** (or **Full**, which also installs MySQL Workbench, useful
   for viewing tables).
3. Keep the default port **3306**.
4. When it asks for a **root password**, choose one and **write it down**. You need it in step 4.4.
5. Keep **"Configure MySQL Server as a Windows Service"** ticked and **"Start at system startup"**.
6. Finish, then check in a new PowerShell: `Get-Service *mysql*` should show `Running`.

### Step 3.6: GitHub access

1. Create an account at https://github.com if you don't have one.
2. Send your GitHub username to Umar. Umar adds you under
   **Settings → Collaborators → Add people**.
3. Accept the invitation email from GitHub.

## 4. Get the project and set it up (once per laptop)

### Step 4.1: Download the project

In PowerShell, go to the folder where you want the project (for example `D:\`) and clone it:

```powershell
cd D:\
git clone https://github.com/UmarHayatAli/NUST-Fruita.git
cd NUST-Fruita
code .
```

VS Code opens the project. From now on, use VS Code's built-in terminal: menu **Terminal → New
Terminal**. It opens already inside the project folder.

### Step 4.2: Install the project's packages

```powershell
npm install
```

This takes a few minutes and creates a `node_modules` folder.

### Step 4.3: Create your private `.env` file

1. Copy the template:

   ```powershell
   copy .env.example .env
   code .env
   ```

2. In the `.env` file, fill in three lines (use letters and numbers only, no spaces):

   ```
   DB_APP_PASSWORD=MakeUpPassword1
   DB_MIGRATOR_PASSWORD=MakeUpPassword2
   JWT_SECRET=
   ```

3. For `JWT_SECRET`, run this in the terminal, copy the long line it prints, and paste it after
   `JWT_SECRET=`:

   ```powershell
   node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
   ```

4. Save with **Ctrl+S**. Do not change any other line.

### Step 4.4: Create the database accounts

Replace `your-root-password` with the MySQL root password from step 3.5:

```powershell
$env:MYSQL_ROOT_PASSWORD='your-root-password'; npm run db:create-users
```

Good result: `Created databases fruita, fruita_test and users [ 'fruita_app', 'fruita_migrator' ]`

This creates two MySQL accounts the app uses (spec 8.5) and two empty databases: `fruita` for
running the app and `fruita_test` for automated tests.

### Step 4.5: Run the tests

```powershell
npm test
```

Good result: all tests pass (green).

### Step 4.6: Start the app

```powershell
npm run dev
```

Open http://localhost:5173 in your browser. You should see **"Hello FRUITA · API: ok ·
Database: ok"**. Press **Ctrl+C** in the terminal to stop.

### Step 4.7: Build the database (from Phase 1 onward)

Once Phase 1 is merged, also run:

```powershell
npm run db:reset
```

This creates all 17 tables, triggers, procedures and views and loads the demo data.

## 5. Daily workflow

Follow these steps for every piece of work.

```powershell
# 1. Get the latest code
git checkout main
git pull

# 2. If the pull changed anything in db/, rebuild your database (from Phase 1)
npm run db:reset

# 3. Make your own branch for the task
git checkout -b feat/cart-page

# 4. ... do the work, run the app and the tests ...
npm test

# 5. Save your work and upload the branch
git add -A
git commit -m "feat(cart): add cart page with quantity stepper"
git push -u origin feat/cart-page
```

Then on GitHub:

1. Click **"Compare & pull request"** on the yellow banner.
2. Write what changed and how you tested it (add screenshots for pages).
3. Ask a teammate to review it.
4. When CI is green and the teammate approves, click **Merge**.
5. Tell the group so the others can `git pull`.

## 6. Team rules

1. **Never work directly on `main`.** Always use a branch and a pull request.
2. **Never commit `.env`.** It is already ignored by Git; don't force-add it.
3. **Never edit a database migration that is already merged.** Add a new numbered file instead.
   Claim the number in the group chat first (V100, V110, V120, ...) so two people don't use the
   same one.
4. **Stay in your own area's files** where possible. If you must change someone else's file,
   tell them first.
5. **Branch names:** `feat/<area>-<name>`, `fix/<name>`, `db/V0xx-<name>`.
6. **Commit messages:** `feat(cart): ...`, `fix(db): ...`, `docs: ...` (Conventional Commits).
7. **Sync points:** at the end of Phases 1, 2, 4, 5 and 6, everyone pulls `main` and runs
   `npm run db:reset` and `npm test`, and checks that everything works on their laptop.
8. **Understand what you merge.** Everyone must be able to explain their area in the viva.

## 7. Build phases and owners

| Phase | Goal                                                                                       | Owner                                                              | Status               |
| ----- | ------------------------------------------------------------------------------------------ | ------------------------------------------------------------------ | -------------------- |
| P0    | Repository, tooling, MySQL, CI                                                             | Umar                                                               | Done (merged, PR #1) |
| P1    | Full database: 17 tables, triggers, procedures, views, seed data, DB tests                 | All three (Umar builds; Tehreem and Aimen review their own tables) | Next                 |
| P2    | Login, register, roles, layouts, forced password change; shared UI components              | Aimen                                                              |                      |
| P3    | Shop, product page, admin products and categories, image upload                            | Tehreem                                                            |                      |
| P4    | Addresses and cart (Aimen); checkout, place and cancel order, my orders (Umar)             | Aimen + Umar                                                       |                      |
| P5    | Admin order handling, rider portal, delivery code, failed delivery                         | Umar                                                               |                      |
| P6    | Admin users, riders, hostels (Aimen); slots, alerts, statistics (Umar); settings (Tehreem) | All three                                                          |                      |
| P7    | Reviews and ratings (Tehreem); wishlist (Aimen)                                            | Tehreem + Aimen                                                    |                      |
| P8    | Animated landing page (can start from week 4)                                              | Tehreem                                                            |                      |
| P9    | Security checks, full tests, accessibility, performance                                    | All three                                                          |                      |
| P10   | README, report, demo rehearsal                                                             | All three                                                          |                      |

Every phase ends with a checklist from spec section 15. A phase is finished only when its
checklist passes, CI is green, and `docs/PROGRESS.md` is updated.

## 8. Scripts

Run these from the project folder.

| Script                    | Does                                                          |
| ------------------------- | ------------------------------------------------------------- |
| `npm install`             | Installs all packages                                         |
| `npm run dev`             | Starts the API (port 4000) and the web app (port 5173)        |
| `npm test`                | Runs all automated tests                                      |
| `npm run lint`            | Checks code style problems                                    |
| `npm run format`          | Auto-formats all files                                        |
| `npm run build`           | Builds the web app into `web/dist`                            |
| `npm run db:create-users` | Creates the `fruita_app` and `fruita_migrator` MySQL accounts |
| `npm run db:reset`        | Deletes and rebuilds the database with demo data (Phase 1)    |

## 9. Folder structure

```
db/        database: migrations (tables, triggers, procedures, views), seed data, scripts
shared/    validation rules and constants used by both server and web
server/    backend: Express REST API
web/       frontend: React website (Vite + Tailwind)
docs/      specification, decisions, progress
.github/   automatic checks (CI) that run on every pull request
```

## 10. Troubleshooting

| Problem                                         | Fix                                                                                                                                                                                                                                                                                                                                 |
| ----------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `'git'`, `'node'` or `'code'` is not recognized | Close PowerShell (and VS Code), open it again. If it still fails, reinstall the tool                                                                                                                                                                                                                                                |
| `Get-Service *mysql*` shows `Stopped`           | Open PowerShell **as Administrator** and run `Start-Service <name>` (use the name shown, for example `MySQL80`)                                                                                                                                                                                                                     |
| `Access denied for user 'root'`                 | The root password in step 4.4 is wrong                                                                                                                                                                                                                                                                                              |
| `Missing environment variables: ...`            | Your `.env` is missing a value; compare it with `.env.example`                                                                                                                                                                                                                                                                      |
| Browser shows `Database: down`                  | MySQL isn't running, or step 4.4 wasn't done                                                                                                                                                                                                                                                                                        |
| `npm run format:check` fails in CI              | Run `npm run format`, then commit again                                                                                                                                                                                                                                                                                             |
| Port 4000 or 5173 already in use                | Another `npm run dev` is still running; close that terminal                                                                                                                                                                                                                                                                         |
| `Could not read package.json`                   | You are in the wrong folder. The terminal line must end with `NUST-Fruita>`; run `cd NUST-Fruita` first                                                                                                                                                                                                                             |
| Forgot the MySQL root password                  | Open MySQL Workbench. Right-click your connection → **Edit Connection** shows the **User Name** (usually `root`). If the connection opens without asking for a password, run `ALTER USER CURRENT_USER() IDENTIFIED BY 'NewPassword1';` in a query tab to set a new one. If it asks for a password you don't know, ask Umar for help |
| Where to keep my passwords                      | In a text file **outside** the `NUST-Fruita` folder (for example one folder up). Git only uploads files inside the project folder                                                                                                                                                                                                   |
