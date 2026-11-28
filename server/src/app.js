// Builds the Express app. Kept separate from server.js so tests can use
// the app with supertest without opening a port.
import express from 'express';
import helmet from 'helmet';
import cookieParser from 'cookie-parser';
import morgan from 'morgan';
import { config } from './config.js';
import { pool } from './db.js';
import { notFound, errorHandler } from './middleware/errors.js';

export const app = express();

app.use(helmet());
app.use(express.json({ limit: '100kb' }));
app.use(cookieParser());
if (!config.isTest) app.use(morgan('dev'));

// Health check (P0 gate): proves the API runs and can reach MySQL.
app.get('/api/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ status: 'ok', db: 'ok' });
  } catch (err) {
    console.error('Health check: database unreachable:', err.message);
    res.status(503).json({ status: 'ok', db: 'down' });
  }
});

app.use('/api', notFound);
app.use(errorHandler);
