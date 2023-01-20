export class Vector2 {
  constructor(public readonly x: number, public readonly y: number) {}

  map(fn: (x: number) => number): Vector2 {
    return new Vector2(fn(this.x), fn(this.y));
  }

  plus(other: Vector2): Vector2 {
    return new Vector2(this.x + other.x, this.y + other.y);
  }

  minus(other: Vector2): Vector2 {
    return new Vector2(this.x - other.x, this.y - other.y);
  }
}

export const vec2 = (x: number, y: number) => new Vector2(x, y);
