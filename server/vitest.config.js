import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    // Tests always use the separate fruita_test database (spec 14).
    env: { NODE_ENV: 'test' },
    include: ['test/**/*.test.js'],
    // Test files share one MySQL database, so run them one at a time.
    fileParallelism: false,
  },
});
