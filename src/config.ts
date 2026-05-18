import fs from 'node:fs';
import path from 'node:path';
import dotenv = require('dotenv');
import { z } from 'zod';

const envSchema = z.object({
  PORT: z.string().optional(),
  LOG_LEVEL: z.string().default('info'),
  ACHIEVEMENT_INTERNAL_KEY: z.string().min(1),
  ACHIEVEMENT_WORKER_CONCURRENCY: z.string().default('3'),
  STRAPI_ADMIN_URL: z.string().default('https://langgo-en-strapi.geniusparentingai.ca/admin/auth/login'),
  ACHIEVEMENT_DB_SCHEMA: z.string().min(1).default('achievement_system'),
  DATABASE_CLIENT: z.string().default('postgres'),
  DATABASE_HOST: z.string().min(1),
  DATABASE_PORT: z.string().default('5432'),
  DATABASE_NAME: z.string().min(1),
  DATABASE_USERNAME: z.string().min(1),
  DATABASE_PASSWORD: z.string().min(1),
  DATABASE_SSL: z.string().default('false'),
  EVENT_BUS_DRIVER: z.string().default('postgres'),
  EVENT_BUS_CHANNEL_PREFIX: z.string().default('event_bus'),
});

function parseBoolean(value: string): boolean {
  return ['1', 'true', 'yes', 'on'].includes(value.toLowerCase());
}

function buildPostgresUrl(parsed: z.infer<typeof envSchema>): string {
  const auth = `${encodeURIComponent(parsed.DATABASE_USERNAME)}:${encodeURIComponent(parsed.DATABASE_PASSWORD)}`;
  const database = encodeURIComponent(parsed.DATABASE_NAME);
  const port = encodeURIComponent(parsed.DATABASE_PORT);

  if (parsed.DATABASE_HOST.startsWith('/')) {
    const host = encodeURIComponent(parsed.DATABASE_HOST);
    return `postgresql://${auth}@/${database}?host=${host}&port=${port}`;
  }

  const host = encodeURIComponent(parsed.DATABASE_HOST);
  return `postgresql://${auth}@${host}:${port}/${database}`;
}

let dotenvLoaded = false;

function loadDotenvIfPresent(): void {
  if (dotenvLoaded) {
    return;
  }

  const envPath = path.resolve(process.cwd(), '.env');
  if (fs.existsSync(envPath)) {
    dotenv.config({ path: envPath });
  }

  dotenvLoaded = true;
}

export interface AppConfig {
  port: number;
  logLevel: string;
  internalKey: string;
  strapiAdminUrl: string;
  schema: string;
  workerConcurrency: number;
  database: {
    host: string;
    port: number;
    database: string;
    user: string;
    password: string;
    ssl: boolean;
  };
  eventBus: {
    driver: 'postgres';
    postgresUrl: string;
    channelPrefix: string;
  };
}

export function loadConfig(env: NodeJS.ProcessEnv = process.env): AppConfig {
  loadDotenvIfPresent();
  const parsed = envSchema.parse(env);

  if (parsed.DATABASE_CLIENT !== 'postgres') {
    throw new Error(`Unsupported DATABASE_CLIENT "${parsed.DATABASE_CLIENT}". Only "postgres" is supported.`);
  }

  if (parsed.EVENT_BUS_DRIVER !== 'postgres') {
    throw new Error(`Unsupported EVENT_BUS_DRIVER "${parsed.EVENT_BUS_DRIVER}". Only "postgres" is supported.`);
  }

  const eventBusPostgresUrl = buildPostgresUrl(parsed);
  const workerConcurrency = Number(parsed.ACHIEVEMENT_WORKER_CONCURRENCY);
  if (!Number.isInteger(workerConcurrency) || workerConcurrency < 1) {
    throw new Error('ACHIEVEMENT_WORKER_CONCURRENCY must be a positive integer.');
  }

  return {
    port: Number(parsed.PORT ?? '8080'),
    logLevel: parsed.LOG_LEVEL,
    internalKey: parsed.ACHIEVEMENT_INTERNAL_KEY,
    strapiAdminUrl: parsed.STRAPI_ADMIN_URL,
    schema: parsed.ACHIEVEMENT_DB_SCHEMA,
    workerConcurrency,
    database: {
      host: parsed.DATABASE_HOST,
      port: Number(parsed.DATABASE_PORT),
      database: parsed.DATABASE_NAME,
      user: parsed.DATABASE_USERNAME,
      password: parsed.DATABASE_PASSWORD,
      ssl: parseBoolean(parsed.DATABASE_SSL),
    },
    eventBus: {
      driver: 'postgres',
      postgresUrl: eventBusPostgresUrl,
      channelPrefix: parsed.EVENT_BUS_CHANNEL_PREFIX,
    },
  };
}
