// Phase 0 placeholder: proves the web app reaches the API through the Vite proxy.
// Replaced by the real router and layouts in Phase 2.
import { useEffect, useState } from 'react';

export default function App() {
  const [health, setHealth] = useState(null);
  const [failed, setFailed] = useState(false);

  useEffect(() => {
    fetch('/api/health')
      .then((res) => res.json())
      .then(setHealth)
      .catch(() => setFailed(true));
  }, []);

  return (
    <main className="min-h-screen flex flex-col items-center justify-center gap-4 p-6">
      <h1 className="font-heading text-5xl font-bold text-brand">Hello FRUITA</h1>
      <p className="text-muted">
        {failed && 'API not reachable. Is the server running on port 4000?'}
        {!failed && !health && 'Checking the API...'}
        {health && `API: ${health.status} · Database: ${health.db}`}
      </p>
    </main>
  );
}
