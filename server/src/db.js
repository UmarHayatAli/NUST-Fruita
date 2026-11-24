// One shared mysql2 connection pool for the whole API.
import mysql from 'mysql2/promise';
import { config } from './config.js';

export const pool = mysql.createPool({
  ...config.db,
  connectionLimit: 10,
  // Security (spec 11): one statement per query, so injected "; DROP ..." cannot run.
  multipleStatements: false,
  // Keep DECIMAL money values as strings ("350.00"), never JS floats (spec 6.3).
  decimalNumbers: false,
  // TIMESTAMPs are read in Pakistan time (spec A12).
  timezone: '+05:00',
});

// Every new connection uses Pakistan time, so NOW() in procedures and views
// matches the delivery slot times (spec 7.1, A12).
pool.on('connection', (conn) => {
  conn.query("SET time_zone = '+05:00'");
});
