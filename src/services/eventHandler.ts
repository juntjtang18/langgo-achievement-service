import type { EventBusMessage } from '../types';
import { normalizeAchievementEventName } from '../eventNames';
import { ProgressService } from './progressService';

function pickUserId(payload: Record<string, any> = {}): string | number | null {
  return payload.userid ?? payload.userId ?? null;
}

function pickUsername(payload: Record<string, any> = {}): string | null {
  return payload.username ?? payload.userName ?? null;
}

export class EventHandlerService {
  constructor(private readonly progressService: ProgressService) {}

  async handle(message: EventBusMessage<Record<string, any>>): Promise<{ updated: number }> {
    const payload = message.payload ?? {};
    const eventName = normalizeAchievementEventName(
      message.topic ||
      payload.eventType ||
      payload.event_name ||
      ''
    );

    return this.progressService.applyEvent({
      event_name: eventName,
      userid: pickUserId(payload)?.toString() ?? null,
      username: pickUsername(payload),
      payload,
    });
  }
}
