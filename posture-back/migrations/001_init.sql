-- Enable extensions for UUID generation
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enums
DO $$ BEGIN
  CREATE TYPE posture_type AS ENUM (
    'normal',
    'turtle',
    'sleep',
    'ambiguous_normal',
    'ambiguous_turtle',
    'ambiguous_sleep'
  );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE event_type AS ENUM (
    'login', 'relogin', 'absent',
    'register_start', 'register_commit'
  );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- users
CREATE TABLE IF NOT EXISTS users (
  user_id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  external_ref   TEXT UNIQUE,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);

-- embeddings
CREATE TABLE IF NOT EXISTS embeddings (
  embedding_id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  dim            INT  NOT NULL DEFAULT 128,
  l2_normalized  BOOLEAN NOT NULL DEFAULT TRUE,
  vec            DOUBLE PRECISION[] NOT NULL,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_embeddings_user ON embeddings(user_id);

-- sessions
CREATE TABLE IF NOT EXISTS sessions (
  session_id     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  start_ts       TIMESTAMPTZ NOT NULL,
  end_ts         TIMESTAMPTZ,
  total_duration_sec INTEGER GENERATED ALWAYS AS (
    CASE WHEN end_ts IS NULL THEN NULL
         ELSE EXTRACT(EPOCH FROM (end_ts - start_ts))::INT END
  ) STORED,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_sessions_user_start ON sessions(user_id, start_ts);

-- posture_logs
CREATE TABLE IF NOT EXISTS posture_logs (
  posture_log_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id     UUID NOT NULL REFERENCES sessions(session_id) ON DELETE CASCADE,
  posture        posture_type NOT NULL,
  start_ts       TIMESTAMPTZ NOT NULL,
  end_ts         TIMESTAMPTZ NOT NULL,
  duration_sec   INTEGER GENERATED ALWAYS AS (
    EXTRACT(EPOCH FROM (end_ts - start_ts))::INT
  ) STORED,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_posture_session_time ON posture_logs(session_id, start_ts);
CREATE INDEX IF NOT EXISTS idx_posture_type ON posture_logs(posture);

-- calibration_baselines
CREATE TABLE IF NOT EXISTS calibration_baselines (
  user_id  UUID PRIMARY KEY REFERENCES users(user_id) ON DELETE CASCADE,
  box_x    INTEGER NOT NULL,
  box_y    INTEGER NOT NULL,
  box_w    INTEGER NOT NULL,
  box_h    INTEGER NOT NULL,
  face_scale DOUBLE PRECISION,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- event_logs
CREATE TABLE IF NOT EXISTS event_logs (
  event_id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event      event_type NOT NULL,
  session_id UUID REFERENCES sessions(session_id) ON DELETE SET NULL,
  user_id    UUID REFERENCES users(user_id) ON DELETE SET NULL,
  ts         TIMESTAMPTZ NOT NULL,
  payload    JSONB NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_event_logs_time ON event_logs(ts);
CREATE INDEX IF NOT EXISTS idx_event_logs_user ON event_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_event_logs_event ON event_logs(event);
