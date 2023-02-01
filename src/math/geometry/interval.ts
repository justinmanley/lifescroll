export class Interval {
  public readonly length: number;

  constructor(public readonly start: number, public readonly end: number) {
    this.length = this.end - this.start;
  }

  center(): number {
    return this.start + this.length / 2;
  }

  contains(other: Interval | number): boolean {
    if (typeof other === "number") {
      return this.start <= other && other <= this.end;
    }
    return this.start <= other.start && other.end <= this.end;
  }
}
