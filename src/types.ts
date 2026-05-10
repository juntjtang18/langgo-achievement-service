export interface AchievementTranslation {
  id: number;
  achievement_id: number;
  locale: string;
  title: string | null;
  description: string | null;
}

export interface AchievementDefinition {
  id: number;
  code: string;
  event_name: string;
  icon_name: string | null;
  points: number;
  goal: number;
  translations: AchievementTranslation[];
}

export interface UserAchievementRow {
  id: number;
  userid: string;
  username: string | null;
  achievement_id: number;
  progress: number;
  achieved: boolean;
  achieved_at: string | null;
}

export interface AchievementResponseRow {
  id: number;
  code: string;
  event_name: string;
  icon_name: string | null;
  points: number;
  goal: number;
  progress: number;
  achieved: boolean;
  achieved_at: string | null;
  title: string | null;
  description: string | null;
}

export interface AchievementEvent {
  event_name: string;
  userid: string | null;
  username: string | null;
  payload: unknown;
}

export interface EventBusMessage<TPayload = unknown> {
  topic: string;
  payload: TPayload;
  publishedAt?: string;
  ack(): Promise<void>;
  nack(): Promise<void>;
}

export interface EventBusSubscriptionHandle {
  topic: string;
  unsubscribe(): Promise<void>;
}

export interface EventBus {
  subscribe<TPayload = unknown>(
    topic: string,
    handler: (message: EventBusMessage<TPayload>) => Promise<void> | void
  ): Promise<EventBusSubscriptionHandle>;
  close(): Promise<void>;
}
