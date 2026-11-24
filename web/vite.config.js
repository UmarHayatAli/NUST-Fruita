import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// The dev server proxies /api and /uploads to the Express API on port 4000,
// so the browser sees one origin and the session cookie just works (spec 10).
export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: {
      '/api': 'http://localhost:4000',
      '/uploads': 'http://localhost:4000',
    },
  },
});
