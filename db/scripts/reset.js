// Deletes the database and builds it again from scratch: create, migrate, seed.
//   npm run db:reset            -> database fruita
//   npm run db:reset -- --test  -> database fruita_test
// Refuses to run in production, because it deletes all data (spec 7.1).
import { connectAsMigrator, isMainModule, targetDatabase } from './lib.js';
import { migrate } from './migrate.js';

export async function reset(database = targetDatabase()) {
  if (process.env.NODE_ENV === 'production') {
    throw new Error('db:reset deletes all data and never runs when NODE_ENV=production');
  }

  const conn = await connectAsMigrator(null);
  try {
    const db = conn.escapeId(database);
    await conn.query(`DROP DATABASE IF EXISTS ${db}`);
    await conn.query(`CREATE DATABASE ${db} CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci`);
    console.log(`${database}: dropped and created`);
  } finally {
    await conn.end();
  }

  await migrate(database);
  // Seed data is added in a later step of Phase 1.
}

if (isMainModule(import.meta.url)) {
  reset().catch((err) => {
    console.error(`Reset failed: ${err.message}`);
    process.exit(1);
  });
}
