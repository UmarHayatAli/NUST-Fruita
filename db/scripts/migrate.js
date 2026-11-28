// Applies the numbered migration files in db/migrations that have not run yet.
//   npm run db:migrate            -> database fruita
//   npm run db:migrate -- --test  -> database fruita_test
//
// Each applied file is recorded in schema_migrations with a SHA-256 checksum.
// If an applied file is edited later, the script stops: never edit a migration
// that already ran, add a new numbered file instead (spec rule 3, section 7.1).
import { createHash } from 'node:crypto';
import { readdir, readFile } from 'node:fs/promises';
import { connectAsMigrator, isMainModule, splitSqlStatements, targetDatabase } from './lib.js';

const MIGRATIONS_DIR = new URL('../migrations/', import.meta.url);

export async function migrate(database = targetDatabase()) {
  const conn = await connectAsMigrator(database);
  try {
    await conn.query(`CREATE TABLE IF NOT EXISTS schema_migrations (
      version    VARCHAR(20) PRIMARY KEY,
      applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      checksum   CHAR(64)
    ) ENGINE=InnoDB`);

    const [rows] = await conn.query('SELECT version, checksum FROM schema_migrations');
    const applied = new Map(rows.map((row) => [row.version, row.checksum]));

    // File names look like V010__users_riders_hostels.sql; sorting by name = version order.
    const files = (await readdir(MIGRATIONS_DIR)).filter((f) => /^V\d+__.+\.sql$/.test(f)).sort();

    let count = 0;
    for (const file of files) {
      const version = file.split('__')[0];
      // Normalise line endings so Windows and Linux compute the same checksum.
      const sql = (await readFile(new URL(file, MIGRATIONS_DIR), 'utf8')).replace(/\r\n/g, '\n');
      const checksum = createHash('sha256').update(sql).digest('hex');

      if (applied.has(version)) {
        if (applied.get(version) !== checksum) {
          throw new Error(
            `${file} was changed after it was applied. Revert the change and add a new migration instead.`
          );
        }
        continue;
      }

      // MySQL cannot roll back DDL, so a file that fails halfway leaves partial changes;
      // fix the file and run "npm run db:reset" (development only).
      for (const statement of splitSqlStatements(sql)) {
        await conn.query(statement);
      }
      await conn.query('INSERT INTO schema_migrations (version, checksum) VALUES (?, ?)', [
        version,
        checksum,
      ]);
      console.log(`  applied ${file}`);
      count += 1;
    }
    console.log(
      count === 0 ? `${database}: already up to date` : `${database}: ${count} migration(s) applied`
    );
  } finally {
    await conn.end();
  }
}

if (isMainModule(import.meta.url)) {
  migrate().catch((err) => {
    console.error(`Migration failed: ${err.message}`);
    process.exit(1);
  });
}
