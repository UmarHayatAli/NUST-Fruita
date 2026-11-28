// Creates the two MySQL accounts from spec section 8.5 and the two empty databases.
// Run it once, as MySQL root:
//   PowerShell:  $env:MYSQL_ROOT_PASSWORD='your-root-password'; npm run db:create-users
//   bash:        MYSQL_ROOT_PASSWORD=... npm run db:create-users
// Passwords for fruita_app and fruita_migrator are read from .env, so no
// password is ever committed to the repository. Running it again is safe:
// it updates the passwords and re-applies the grants.
import 'dotenv/config';
import mysql from 'mysql2/promise';

const required = ['DB_APP_USER', 'DB_APP_PASSWORD', 'DB_MIGRATOR_USER', 'DB_MIGRATOR_PASSWORD'];
const missing = required.filter((name) => !process.env[name]);
if (missing.length > 0) {
  console.error(`Missing in .env: ${missing.join(', ')}`);
  process.exit(1);
}
if (process.env.MYSQL_ROOT_PASSWORD === undefined) {
  console.error('Set MYSQL_ROOT_PASSWORD in the environment first (see the comment at the top).');
  process.exit(1);
}

const dbName = process.env.DB_NAME || 'fruita';
const testDbName = process.env.DB_NAME_TEST || 'fruita_test';

const root = await mysql.createConnection({
  host: process.env.DB_HOST || '127.0.0.1',
  port: Number(process.env.DB_PORT || 3306),
  user: process.env.MYSQL_ROOT_USER || 'root',
  password: process.env.MYSQL_ROOT_PASSWORD,
});

try {
  for (const db of [dbName, testDbName]) {
    // Database names cannot be ? placeholders; escapeId quotes them safely.
    await root.query(
      `CREATE DATABASE IF NOT EXISTS ${root.escapeId(db)} CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci`
    );
  }

  const accounts = [
    { user: process.env.DB_APP_USER, password: process.env.DB_APP_PASSWORD },
    { user: process.env.DB_MIGRATOR_USER, password: process.env.DB_MIGRATOR_PASSWORD },
  ];
  for (const { user, password } of accounts) {
    // '%' lets the account connect from Docker as well as localhost.
    await root.query('CREATE USER IF NOT EXISTS ?@? IDENTIFIED BY ?', [user, '%', password]);
    await root.query('ALTER USER ?@? IDENTIFIED BY ?', [user, '%', password]);
  }

  for (const db of [dbName, testDbName]) {
    const dbId = root.escapeId(db);
    // API account: data access and procedure calls only, no DDL (spec 8.5, section 11).
    await root.query(`GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON ${dbId}.* TO ?@?`, [
      process.env.DB_APP_USER,
      '%',
    ]);
    // Migrator: everything on the project databases, used only by db scripts.
    await root.query(`GRANT ALL PRIVILEGES ON ${dbId}.* TO ?@?`, [
      process.env.DB_MIGRATOR_USER,
      '%',
    ]);
  }

  console.log(
    `Created databases ${dbName}, ${testDbName} and users`,
    accounts.map((a) => a.user)
  );
} finally {
  await root.end();
}
