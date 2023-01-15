export class LifeGridInterval {
  public readonly length: number;

  constructor(public readonly start: number, public readonly end: number) {
    this.length = end - start;
  }

  center(): number {
    return Math.floor(this.start + this.length / 2);
  }
}
