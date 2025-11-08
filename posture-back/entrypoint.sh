#!/bin/sh
set -e

echo "Waiting for database..."
# crude wait loop
RETRIES=30
until pg_isready -d "$DATABASE_URL" -q || [ $RETRIES -eq 0 ]; do
  echo "  DB not ready, retrying... ($RETRIES)"
  RETRIES=$((RETRIES-1))
  sleep 2
done

echo "Running migrations..."
psql "$DATABASE_URL" -f migrations/001_init.sql

echo "Starting server..."
node src/index.js
