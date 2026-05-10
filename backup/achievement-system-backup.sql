-- Baseline standalone achievement schema restore.
CREATE TABLE IF NOT EXISTS {{SCHEMA}}.as_achievements (
  id BIGSERIAL PRIMARY KEY,
  code VARCHAR(255) NOT NULL UNIQUE,
  event_name VARCHAR(255) NOT NULL,
  icon_name VARCHAR(255),
  points INTEGER NOT NULL DEFAULT 1,
  goal INTEGER NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS {{SCHEMA}}.as_achievement_translations (
  id BIGSERIAL PRIMARY KEY,
  achievement_id BIGINT NOT NULL REFERENCES {{SCHEMA}}.as_achievements(id) ON DELETE CASCADE,
  locale VARCHAR(50) NOT NULL DEFAULT 'en',
  title VARCHAR(255),
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (achievement_id, locale)
);

CREATE TABLE IF NOT EXISTS {{SCHEMA}}.as_event_lists (
  id BIGSERIAL PRIMARY KEY,
  event_name VARCHAR(255) NOT NULL,
  points INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS {{SCHEMA}}.as_user_achievements (
  id BIGSERIAL PRIMARY KEY,
  userid VARCHAR(255) NOT NULL,
  username VARCHAR(255),
  achievement_id BIGINT NOT NULL REFERENCES {{SCHEMA}}.as_achievements(id) ON DELETE CASCADE,
  progress INTEGER NOT NULL DEFAULT 0,
  achieved BOOLEAN NOT NULL DEFAULT FALSE,
  achieved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (userid, achievement_id)
);

CREATE INDEX IF NOT EXISTS as_achievements_event_name_idx
  ON {{SCHEMA}}.as_achievements (event_name);

CREATE INDEX IF NOT EXISTS as_achievement_translations_locale_idx
  ON {{SCHEMA}}.as_achievement_translations (locale);

CREATE INDEX IF NOT EXISTS as_event_lists_event_name_idx
  ON {{SCHEMA}}.as_event_lists (event_name);

CREATE INDEX IF NOT EXISTS as_user_achievements_userid_idx
  ON {{SCHEMA}}.as_user_achievements (userid);
