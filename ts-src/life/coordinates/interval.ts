export class LifeGridInterval {
  public readonly length: number;

  constructor(public readonly start: number, public readonly end: number) {
    if (end < start) {
      throw new Error(
        `Interval start must be less than or equal to its end, but ${end} < ${start}.`
      );
    }

    this.length = end - start;
  }

  center(): number {
    return Math.floor(this.start + this.length / 2);
  }

  intersects(other: LifeGridInterval): boolean {
    return other.start < this.end || this.start < other.end;
  }

  contains(other: LifeGridInterval | number): boolean {
    if (typeof other === "number") {
      return this.start <= other && other <= this.end;
    }
    return this.start <= other.start && other.end <= this.end;
  }
}
