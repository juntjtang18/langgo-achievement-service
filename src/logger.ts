import { Writable } from 'node:stream';
import pino, { type Logger } from 'pino';

type LogRecord = {
  level?: number;
  time?: string;
  msg?: string;
  module?: string;
  action?: string;
  responseCode?: number | string;
  response?: string;
  statusCode?: number;
  responseTime?: number;
  port?: number;
  schema?: string;
  signal?: string;
  driver?: string;
  channelPrefix?: string;
  eventCount?: number;
  eventNames?: string[];
  eventName?: string;
  userid?: string | number;
  req?: { method?: string; url?: string };
  res?: { statusCode?: number };
  err?: { message?: string };
  [key: string]: unknown;
};

const EVENT_BUS_MESSAGE_MAP: Record<string, string> = {
  '[event-bus-client] initializing event bus': 'Event bus client initialized',
  '[event-bus-client] closing event bus': 'Event bus client closed',
  '[event-bus-client] connecting Postgres publisher': 'Connecting Postgres event publisher',
  '[event-bus-client] connecting Postgres subscriber': 'Connecting Postgres event bus subscriber',
  '[event-bus-client] publishing event': 'Publishing event to event bus',
  '[event-bus-client] closing Postgres driver': 'Closing Postgres event bus driver',
};

const SUPPRESSED_EVENT_BUS_MESSAGES = new Set([
  '[event-bus-client] subscribing to event',
  '[event-bus-client] unsubscribing from event',
]);

const LEVEL_LABELS: Record<number, string> = {
  10: 'Trace',
  20: 'Debug',
  30: 'Info',
  40: 'Warn',
  50: 'Error',
  60: 'Fatal',
};

const RESERVED_KEYS = new Set([
  'level',
  'time',
  'msg',
  'module',
  'action',
  'responseCode',
  'response',
  'statusCode',
  'responseTime',
  'port',
  'schema',
  'signal',
  'driver',
  'channelPrefix',
  'eventCount',
  'eventNames',
  'eventName',
  'userid',
  'req',
  'res',
  'err',
]);

export function createLogger(level: string) {
  return pino(
    {
      level,
      base: undefined,
      timestamp: pino.stdTimeFunctions.isoTime,
    },
    createFormattedDestination()
  );
}

export function createEventBusLogger(logger: Logger) {
  return {
    info(message: string, meta?: Record<string, unknown>) {
      if (SUPPRESSED_EVENT_BUS_MESSAGES.has(message)) {
        return;
      }

      logger.info(meta ?? {}, EVENT_BUS_MESSAGE_MAP[message] ?? message);
    },
    warn(message: string, meta?: Record<string, unknown>) {
      logger.warn(meta ?? {}, EVENT_BUS_MESSAGE_MAP[message] ?? message);
    },
    error(message: string, meta?: Record<string, unknown>) {
      logger.error(meta ?? {}, EVENT_BUS_MESSAGE_MAP[message] ?? message);
    },
  };
}

function createFormattedDestination() {
  let buffer = '';

  return new Writable({
    write(chunk, _encoding, callback) {
      buffer += chunk.toString();
      const lines = buffer.split('\n');
      buffer = lines.pop() ?? '';

      for (const line of lines) {
        if (!line.trim()) continue;

        try {
          const record = JSON.parse(line) as LogRecord;
          process.stdout.write(`${formatRecord(record)}\n`);
        } catch {
          process.stdout.write(`${line}\n`);
        }
      }

      callback();
    },
    final(callback) {
      if (buffer.trim()) {
        try {
          const record = JSON.parse(buffer) as LogRecord;
          process.stdout.write(`${formatRecord(record)}\n`);
        } catch {
          process.stdout.write(`${buffer}\n`);
        }
      }
      callback();
    },
  });
}

function formatRecord(record: LogRecord): string {
  const datetime = record.time ?? new Date().toISOString();
  const level = LEVEL_LABELS[record.level ?? 30] ?? 'Info';
  const module = inferModule(record);
  const action = truncate160(record.action ?? inferAction(record));
  const responseCode = String(record.responseCode ?? record.res?.statusCode ?? record.statusCode ?? '-');
  const response = truncate160(record.response ?? inferResponse(record));
  return `[${datetime}] <${level}>[${module}] [${action}] [${responseCode}] [${response}]`;
}

function inferModule(record: LogRecord): string {
  if (record.module) return record.module;
  if (record.req) return 'HTTP';
  if (record.schema) return 'Database';
  if (record.port || record.signal) return 'Server';
  if (record.eventNames || record.eventName || String(record.msg || '').toLowerCase().includes('event bus')) return 'EventBus';
  if (String(record.msg || '').toLowerCase().includes('admin')) return 'Admin';
  if (String(record.msg || '').toLowerCase().includes('achievement')) return 'Achievement';
  return 'App';
}

function inferAction(record: LogRecord): string {
  if (record.req) {
    return `${record.req.method ?? 'HTTP'} ${record.req.url ?? '/'}`;
  }
  return record.msg ?? 'Log';
}

function inferResponse(record: LogRecord): string {
  if (record.req) {
    return `responseTime=${record.responseTime ?? 0}ms`;
  }
  if (record.err?.message) {
    return record.err.message;
  }
  if (typeof record.schema === 'string') {
    return `schema=${record.schema}`;
  }
  if (typeof record.port === 'number') {
    return `port=${record.port}`;
  }
  if (typeof record.signal === 'string') {
    return `signal=${record.signal}`;
  }
  if (record.eventCount && Array.isArray(record.eventNames)) {
    return `${record.eventCount} topics: ${record.eventNames.join(', ')}`;
  }
  if (typeof record.eventName === 'string') {
    return `event=${record.eventName}`;
  }
  if (typeof record.userid !== 'undefined') {
    return `userid=${record.userid}`;
  }
  if (typeof record.driver === 'string' && typeof record.channelPrefix === 'string') {
    return `driver=${record.driver}, channelPrefix=${record.channelPrefix}`;
  }

  const meta = Object.entries(record)
    .filter(([key, value]) => !RESERVED_KEYS.has(key) && value != null)
    .slice(0, 4)
    .map(([key, value]) => `${key}=${stringifyValue(value)}`);

  return meta.length > 0 ? meta.join(', ') : '-';
}

function stringifyValue(value: unknown): string {
  if (typeof value === 'string') return value;
  if (typeof value === 'number' || typeof value === 'boolean') return String(value);
  try {
    return JSON.stringify(value);
  } catch {
    return String(value);
  }
}

function truncate160(value: string): string {
  const normalized = value.replace(/\s+/g, ' ').trim();
  if (normalized.length <= 160) {
    return normalized || '-';
  }
  return `${normalized.slice(0, 157)}...`;
}
