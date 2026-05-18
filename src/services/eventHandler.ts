import type { EventBusMessage } from '../types';
import { normalizeAchievementEventName } from '../eventNames';
import { ProgressService } from './progressService';
import { AchievementRepository } from '../repositories/achievementRepository';

function pickUserId(payload: Record<string, any> = {}): string | number | null {
  return payload.userid ?? payload.userId ?? null;
}

function pickUsername(payload: Record<string, any> = {}): string | null {
  return payload.username ?? payload.userName ?? null;
}

export class EventHandlerService {
  constructor(
    private readonly progressService: ProgressService,
    private readonly repository: AchievementRepository
  ) {}

  async handle(message: EventBusMessage<Record<string, any>>): Promise<{ updated: number }> {
    const payload = message.payload ?? {};
    const eventName = normalizeAchievementEventName(
      message.topic ||
      payload.eventType ||
      payload.event_name ||
      ''
    );
    const event = {
      event_name: eventName,
      userid: pickUserId(payload)?.toString() ?? null,
      username: pickUsername(payload),
      payload,
    };
    const eventLogId = await this.repository.insertEventLog({
      event_name: event.event_name,
      userid: event.userid,
      username: event.username,
      payload_json: event.payload,
    });

    try {
      const result = await this.progressService.applyEvent({
        ...event,
        eventLogId,
      });
      await this.repository.markEventLogHandled(eventLogId, {
        ok: true,
        updated: result.updated,
      });
      return result;
    } catch (error) {
      await this.repository.markEventLogFailed(eventLogId, {
        ok: false,
        error: error instanceof Error ? error.message : String(error),
      });
      throw error;
    }
  }
}
