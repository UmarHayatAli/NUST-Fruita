// Helpers shared by the database scripts (migrate, reset, seed).
import { fileURLToPath } from 'node:url';
import dotenv from 'dotenv';
import mysql from 'mysql2/promise';

dotenv.config({ path: fileURLToPath(new URL('../../.env', import.meta.url)) });

// Which database to work on: the test database when NODE_ENV=test or --test is given.
export function targetDatabase() {
  const useTest = process.env.NODE_ENV === 'test' || process.argv.includes('--test');
  return useTest ? process.env.DB_NAME_TEST || 'fruita_test' : process.env.DB_NAME || 'fruita';
}

// Connects as fruita_migrator, the only account allowed to change the schema (spec 8.5).
// Pass database = null to connect without selecting a database (needed to DROP/CREATE it).
export async function connectAsMigrator(database) {
  for (const name of ['DB_MIGRATOR_USER', 'DB_MIGRATOR_PASSWORD']) {
    if (!process.env[name]) throw new Error(`Missing ${name} in .env`);
  }
  const conn = await mysql.createConnection({
    host: process.env.DB_HOST || '127.0.0.1',
    port: Number(process.env.DB_PORT || 3306),
    user: process.env.DB_MIGRATOR_USER,
    password: process.env.DB_MIGRATOR_PASSWORD,
    database: database ?? undefined,
    multipleStatements: false,
    timezone: '+05:00',
  });
  // Pakistan time, so NOW() inside procedures matches slot times (spec A12, 7.1).
  await conn.query("SET time_zone = '+05:00'");
  return conn;
}

// Splits a .sql file into single statements, because the connection runs one
// statement at a time (multipleStatements: false). Understands "DELIMITER $$",
// which files with triggers and procedures use so that the ";" inside a
// BEGIN ... END body does not end the statement early (spec 7.1).
// Full-line "--" comments are dropped; a statement must end at the end of a line.
export function splitSqlStatements(sql) {
  const statements = [];
  let delimiter = ';';
  let current = [];

  for (const rawLine of sql.replace(/\r\n/g, '\n').split('\n')) {
    const line = rawLine.trimEnd();
    const trimmed = line.trim();

    const delimiterChange = trimmed.match(/^DELIMITER\s+(\S+)$/i);
    if (delimiterChange) {
      delimiter = delimiterChange[1];
      continue;
    }
    if (trimmed === '' || trimmed.startsWith('--')) continue;

    current.push(line);
    if (trimmed.endsWith(delimiter)) {
      const statement = current.join('\n').slice(0, -delimiter.length).trim();
      if (statement) statements.push(statement);
      current = [];
    }
  }

  const leftover = current.join('\n').trim();
  if (leftover) throw new Error(`SQL ends without "${delimiter}":\n${leftover.slice(0, 200)}`);
  return statements;
}

// True when the script file was run directly with node (not imported).
export function isMainModule(importMetaUrl) {
  return fileURLToPath(importMetaUrl) === process.argv[1];
}
