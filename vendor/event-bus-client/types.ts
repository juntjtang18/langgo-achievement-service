export interface EventBusLogger {
  info(message: string, meta?: Record<string, unknown>): void;
  warn?(message: string, meta?: Record<string, unknown>): void;
  error?(message: string, meta?: Record<string, unknown>): void;
}

export interface EventMessage<TPayload = unknown> {
  topic: string;
  payload: TPayload;
  publishedAt?: string;
  raw?: unknown;
  ack(): Promise<void>;
  nack(): Promise<void>;
}

export interface SubscriptionHandle {
  topic: string;
  unsubscribe(): Promise<void>;
}

export interface EventBus {
  subscribe<TPayload = unknown>(
    topic: string,
    handler: (message: EventMessage<TPayload>) => Promise<void> | void
  ): Promise<SubscriptionHandle>;
  close(): Promise<void>;
}
