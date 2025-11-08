# Posture MVP Server (Express + PostgreSQL)

Minimal backend implementing:
- `/api/events` (login/relogin/absent/register_start/register_commit)
- `/api/postures` (interval logs when posture changes)
- `/api/stats/today` (today-only stats with ratios)

## Quick start

1) Install deps
```bash
npm i
```

2) Set environment and run migration
```bash
cp .env.example .env
# edit DATABASE_URL to your Postgres
npm run migrate
```

3) Run
```bash
npm run dev
# Server on http://localhost:${PORT:-8080}
```

## Test with curl

```bash
curl -X POST http://localhost:8080/api/events \
  -H "Content-Type: application/json" \
  -d '{"event":"login","user_id":"00000000-0000-0000-0000-000000000001","ts":"2025-11-08T00:00:00Z","calibration_trigger":true,"match_sim":0.78}'

curl -X POST http://localhost:8080/api/postures \
  -H "Content-Type: application/json" \
  -d '{"user_id":"00000000-0000-0000-0000-000000000001","posture":"normal","start_ts":"2025-11-08T00:00:02Z","end_ts":"2025-11-08T00:10:02Z"}'

curl "http://localhost:8080/api/stats/today?user_id=00000000-0000-0000-0000-000000000001"
```

## Notes
- Uses server-side mapping rules described in the project spec.
- `COLLECT_AMBIGUOUS` env toggles whether `ambiguous_*` rows are counted.
- For production, add auth, validation, and proper logging.

## Docker (no Node.js needed on host)
```bash
cp .env.example .env  # optional; compose already sets DB for you
docker compose up --build
# API: http://localhost:8080/health
```
