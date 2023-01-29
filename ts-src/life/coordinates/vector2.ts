import { Vector2 } from "../../math/linear-algebra/vector2";
import { fromPage, toPage } from "./mappings";
import { Decoder, Functor, struct, number } from "io-ts/Decoder";

export class LifeGridVector2 {
  constructor(public readonly x: number, public readonly y: number) {}

  static fromPage(
    pageCoordinate: Vector2,
    cellSizeInPixels: number
  ): LifeGridVector2 {
    const convert = fromPage(cellSizeInPixels);
    return new LifeGridVector2(
      convert(pageCoordinate.x),
      convert(pageCoordinate.y)
    );
  }

  static fromTuple([x, y]: [number, number]): LifeGridVector2 {
    return new LifeGridVector2(x, y);
  }

  toPage(cellSizeInPixels: number): Vector2 {
    const convert = toPage(cellSizeInPixels);
    return new Vector2(convert(this.x), convert(this.y));
  }

  plus(other: LifeGridVector2): LifeGridVector2 {
    return new LifeGridVector2(this.x + other.x, this.y + other.y);
  }

  minus(other: LifeGridVector2): LifeGridVector2 {
    return new LifeGridVector2(this.x - other.x, this.y - other.y);
  }

  map(fn: (coord: number) => number): LifeGridVector2 {
    return new LifeGridVector2(fn(this.x), fn(this.y));
  }

  equals(other: LifeGridVector2): boolean {
    return other.x === this.x && other.y === this.y;
  }

  static decoder: Decoder<unknown, LifeGridVector2> = Functor.map(
    struct({ x: number, y: number }),
    ({ x, y }) => new LifeGridVector2(x, y)
  );
}
