export class Interval {
  public readonly length: number;

  constructor(public readonly start: number, public readonly end: number) {
    this.length = this.end - this.start;
  }

  center(): number {
    return this.start + this.length / 2;
  }
}
