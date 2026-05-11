import fs from 'node:fs';
import path from 'node:path';
import dotenv = require('dotenv');
import { z } from 'zod';

const envSchema = z.object({
  PORT: z.string().optional(),
  LOG_LEVEL: z.string().default('info'),
  ACHIEVEMENT_INTERNAL_KEY: z.string().min(1),
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
  EVENT_BUS_POSTGRES_URL: z.string().min(1),
  EVENT_BUS_CHANNEL_PREFIX: z.string().default('event_bus'),
});

function parseBoolean(value: string): boolean {
  return ['1', 'true', 'yes', 'on'].includes(value.toLowerCase());
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
  database: {
    host: string;
    port: number;
    database: string;
    user: string;
    password: string;
    ssl: boolean;
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

  return {
    port: Number(parsed.PORT ?? '8080'),
    logLevel: parsed.LOG_LEVEL,
    internalKey: parsed.ACHIEVEMENT_INTERNAL_KEY,
    strapiAdminUrl: parsed.STRAPI_ADMIN_URL,
    schema: parsed.ACHIEVEMENT_DB_SCHEMA,
    database: {
      host: parsed.DATABASE_HOST,
      port: Number(parsed.DATABASE_PORT),
      database: parsed.DATABASE_NAME,
      user: parsed.DATABASE_USERNAME,
      password: parsed.DATABASE_PASSWORD,
      ssl: parseBoolean(parsed.DATABASE_SSL),
    },
  };
}
