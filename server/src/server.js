// Entry point: starts the HTTP server.
import { app } from './app.js';
import { config } from './config.js';

app.listen(config.port, () => {
  console.log(`FRUITA API listening on http://localhost:${config.port} (${config.env})`);
});
