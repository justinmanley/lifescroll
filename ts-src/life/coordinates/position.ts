import { Vector2 } from "../../math/linear-algebra/vector2";
import { fromPage, toPage } from "./mappings";

export class LifeGridPosition extends Vector2 {
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
    return this.map(toPage(cellSizeInPixels));
  }
}
