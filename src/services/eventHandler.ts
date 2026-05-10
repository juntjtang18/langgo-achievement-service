import type { EventBusMessage } from '../types';
import { ProgressService } from './progressService';

function pickUserId(payload: Record<string, any> = {}): string | number | null {
  return (
    payload.userid ??
    payload.userId ??
    payload.review?.userid ??
    payload.review?.userId ??
    payload.flashcard?.userid ??
    payload.flashcard?.userId ??
    payload.article?.userid ??
    payload.article?.userId ??
    null
  );
}

function pickUsername(payload: Record<string, any> = {}): string | null {
  return (
    payload.username ??
    payload.userName ??
    payload.review?.username ??
    payload.review?.userName ??
    payload.flashcard?.username ??
    payload.flashcard?.userName ??
    payload.article?.username ??
    payload.article?.userName ??
    null
  );
}

export class EventHandlerService {
  constructor(private readonly progressService: ProgressService) {}

  async handle(message: EventBusMessage<Record<string, any>>): Promise<{ updated: number }> {
    const payload = message.payload ?? {};
    const eventName =
      message.topic ||
      payload.event_name ||
      payload.eventName ||
      '';

    return this.progressService.applyEvent({
      event_name: eventName,
      userid: pickUserId(payload)?.toString() ?? null,
      username: pickUsername(payload),
      payload,
    });
  }
}
