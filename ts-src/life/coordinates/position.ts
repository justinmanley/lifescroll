import { Vector2 } from "../../math/linear-algebra/vector2";
import { fromPage, toPage } from "./mappings";

export class LifeGridPosition {
  constructor(public readonly x: number, public readonly y: number) {}

  static fromPage(
    pageCoordinate: Vector2,
    cellSizeInPixels: number
  ): LifeGridPosition {
    const convert = fromPage(cellSizeInPixels);
    return new LifeGridPosition(
      convert(pageCoordinate.x),
      convert(pageCoordinate.y)
    );
  }

  toPage(cellSizeInPixels: number): Vector2 {
    const convert = toPage(cellSizeInPixels);
    return new Vector2(convert(this.x), convert(this.y));
  }

  plus(other: LifeGridPosition): LifeGridPosition {
    return new LifeGridPosition(this.x + other.x, this.y + other.y);
  }

  minus(other: LifeGridPosition): LifeGridPosition {
    return new LifeGridPosition(this.x - other.x, this.y - other.y);
  }

  map(fn: (coord: number) => number): LifeGridPosition {
    return new LifeGridPosition(fn(this.x), fn(this.y));
  }
}
