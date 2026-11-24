import { afterAll, describe, expect, it } from 'vitest';
import request from 'supertest';
import { app } from '../src/app.js';
import { pool } from '../src/db.js';

afterAll(async () => {
  await pool.end();
});

describe('GET /api/health', () => {
  it('reports the API and the database as ok', async () => {
    const res = await request(app).get('/api/health');
    expect(res.status).toBe(200);
    expect(res.body).toEqual({ status: 'ok', db: 'ok' });
  });

  it('returns the standard error shape for unknown API routes', async () => {
    const res = await request(app).get('/api/does-not-exist');
    expect(res.status).toBe(404);
    expect(res.body.error.code).toBe('ERR_NOT_FOUND');
  });
});
