// Loads settings from the root .env file and fails fast if anything is missing,
// so a misconfigured server never starts half-working.
import { fileURLToPath } from 'node:url';
import dotenv from 'dotenv';

dotenv.config({ path: fileURLToPath(new URL('../../.env', import.meta.url)) });

const REQUIRED = [
  'NODE_ENV',
  'PORT',
  'DB_HOST',
  'DB_PORT',
  'DB_NAME',
  'DB_NAME_TEST',
  'DB_APP_USER',
  'DB_APP_PASSWORD',
  'JWT_SECRET',
];

const missing = REQUIRED.filter((name) => !process.env[name]);
if (missing.length > 0) {
  throw new Error(`Missing environment variables: ${missing.join(', ')} (see .env.example)`);
}

const env = process.env.NODE_ENV;

export const config = {
  env,
  isProduction: env === 'production',
  isTest: env === 'test',
  port: Number(process.env.PORT),
  db: {
    host: process.env.DB_HOST,
    port: Number(process.env.DB_PORT),
    // Tests never touch the real database.
    database: env === 'test' ? process.env.DB_NAME_TEST : process.env.DB_NAME,
    user: process.env.DB_APP_USER,
    password: process.env.DB_APP_PASSWORD,
  },
  jwtSecret: process.env.JWT_SECRET,
  cookieSecure: process.env.COOKIE_SECURE === 'true',
  uploadDir: process.env.UPLOAD_DIR || 'server/uploads',
  corsOrigin: process.env.CORS_ORIGIN,
};
