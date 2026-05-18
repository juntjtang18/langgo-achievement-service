ALTER TABLE {{SCHEMA}}.as_event_logs
  ADD COLUMN IF NOT EXISTS status TEXT;

ALTER TABLE {{SCHEMA}}.as_event_logs
  ADD COLUMN IF NOT EXISTS handle_result JSONB;

ALTER TABLE {{SCHEMA}}.as_event_logs
  ADD COLUMN IF NOT EXISTS handled_at TIMESTAMPTZ;

UPDATE {{SCHEMA}}.as_event_logs
SET status = 'handled'
WHERE status IS NULL;

UPDATE {{SCHEMA}}.as_event_logs
SET handled_at = COALESCE(handled_at, received_at, NOW())
WHERE status = 'handled'
  AND handled_at IS NULL;

ALTER TABLE {{SCHEMA}}.as_event_logs
  ALTER COLUMN status SET DEFAULT 'handled';

ALTER TABLE {{SCHEMA}}.as_event_logs
  ALTER COLUMN status SET NOT NULL;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'as_event_logs_status_check'
      AND conrelid = '{{SCHEMA}}.as_event_logs'::regclass
  ) THEN
    ALTER TABLE {{SCHEMA}}.as_event_logs
      ADD CONSTRAINT as_event_logs_status_check
      CHECK (status IN ('processing', 'handled', 'failed', 'ignored'));
  END IF;
END $$;
