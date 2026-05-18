type QueueTask<T> = {
  key: string;
  run: () => Promise<T>;
  resolve: (value: T) => void;
  reject: (error: unknown) => void;
};

export class AchievementEventQueue {
  private readonly pending: Array<QueueTask<unknown>> = [];
  private readonly runningKeys = new Set<string>();
  private activeCount = 0;

  constructor(private readonly maxConcurrency = 3) {
    if (!Number.isInteger(maxConcurrency) || maxConcurrency < 1) {
      throw new Error('AchievementEventQueue maxConcurrency must be a positive integer.');
    }
  }

  enqueue<T>(key: string | null | undefined, run: () => Promise<T>): Promise<T> {
    return new Promise<T>((resolve, reject) => {
      this.pending.push({
        key: key || '__unknown__',
        run,
        resolve: resolve as (value: unknown) => void,
        reject,
      });
      this.drain();
    });
  }

  get size(): number {
    return this.pending.length;
  }

  get active(): number {
    return this.activeCount;
  }

  private drain(): void {
    while (this.activeCount < this.maxConcurrency) {
      const index = this.pending.findIndex((task) => !this.runningKeys.has(task.key));
      if (index === -1) {
        return;
      }

      const [task] = this.pending.splice(index, 1);
      this.start(task);
    }
  }

  private start<T>(task: QueueTask<T>): void {
    this.activeCount += 1;
    this.runningKeys.add(task.key);

    void task.run()
      .then(task.resolve, task.reject)
      .finally(() => {
        this.runningKeys.delete(task.key);
        this.activeCount -= 1;
        this.drain();
      });
  }
}
