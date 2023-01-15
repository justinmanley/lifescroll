export class Vector2 {
  constructor(public readonly x: number, public readonly y: number) {}

  map(fn: (x: number) => number): Vector2 {
    return new Vector2(fn(this.x), fn(this.y));
  }
}
