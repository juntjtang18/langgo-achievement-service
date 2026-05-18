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
  eventLogId: number;
}

export interface EventLogRow {
  id: number;
  event_name: string;
  userid: string | null;
  username: string | null;
  payload_json: unknown;
  received_at: string;
  status: 'processing' | 'handled' | 'failed' | 'ignored';
  handle_result: unknown | null;
  handled_at: string | null;
}

export interface AchievementChangeLogRow {
  id: number;
  event_log_id: number;
  achievement_id: number;
  user_achievement_id: number;
  event_name: string;
  userid: string;
  username: string | null;
  points_added: number;
  progress_before: number;
  progress_after: number;
  achieved_before: boolean;
  achieved_after: boolean;
  achieved_at: string | null;
  created_at: string;
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
  publish<TPayload = unknown>(
    topic: string,
    payload: TPayload
  ): Promise<{
    driver: string;
    topic: string;
    messageId?: string;
    publishedAt: string;
  }>;
  subscribe<TPayload = unknown>(
    topic: string,
    handler: (message: EventBusMessage<TPayload>) => Promise<void> | void
  ): Promise<EventBusSubscriptionHandle>;
  close(): Promise<void>;
}
