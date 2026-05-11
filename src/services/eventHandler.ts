import type { EventBusMessage } from '../types';
import { ProgressService } from './progressService';

function pickUserId(payload: Record<string, any> = {}): string | number | null {
  return payload.userid ?? null;
}

function pickUsername(payload: Record<string, any> = {}): string | null {
  return payload.username ?? null;
}

export class EventHandlerService {
  constructor(private readonly progressService: ProgressService) {}

  async handle(message: EventBusMessage<Record<string, any>>): Promise<{ updated: number }> {
    const payload = message.payload ?? {};
    const eventName =
      message.topic ||
      payload.event_name ||
      '';

    return this.progressService.applyEvent({
      event_name: eventName,
      userid: pickUserId(payload)?.toString() ?? null,
      username: pickUsername(payload),
      payload,
    });
  }
}
