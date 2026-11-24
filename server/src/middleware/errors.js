// Central error handling. Phase 2 adds the mapping of database errors
// (ERR_ codes, CHECK and duplicate-key violations) to HTTP statuses.
import { config } from '../config.js';

// Unknown /api routes return the standard error shape instead of HTML.
export function notFound(req, res) {
  res.status(404).json({ error: { code: 'ERR_NOT_FOUND', message: 'Route not found' } });
}

// Express treats a middleware as an error handler only when it takes 4 arguments.
export function errorHandler(err, req, res, _next) {
  console.error(err);
  res.status(err.status || 500).json({
    error: {
      code: err.code && String(err.code).startsWith('ERR_') ? err.code : 'ERR_INTERNAL',
      // Never leak stack traces or SQL text in production (spec 11).
      message: config.isProduction ? 'Something went wrong' : err.message,
    },
  });
}
