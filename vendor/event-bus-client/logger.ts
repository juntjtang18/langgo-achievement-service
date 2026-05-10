import type { EventBusLogger } from './types';

export function maskConnectionString(value: string): string {
  return value.replace(/:\/\/([^:]+):([^@]+)@/, '://$1:***@');
}

export function resolveLogger(logger?: EventBusLogger): EventBusLogger {
  if (logger) {
    return logger;
  }

  return {
    info(message, meta) {
      // eslint-disable-next-line no-console
      console.log(message, meta ?? {});
    },
    warn(message, meta) {
      // eslint-disable-next-line no-console
      console.warn(message, meta ?? {});
    },
    error(message, meta) {
      // eslint-disable-next-line no-console
      console.error(message, meta ?? {});
    },
  };
}
