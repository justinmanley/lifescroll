import { BoundingRectangle } from "../../math/geometry/bounding-rectangle";
import { fromPage, toPage } from "./mappings";

export class LifeGridBoundingRectangle extends BoundingRectangle {
  static fromPage(
    pageBounds: BoundingRectangle,
    cellSizeInPixels: number
  ): LifeGridBoundingRectangle {
    const convert = fromPage(cellSizeInPixels);
    return new LifeGridBoundingRectangle({
      top: convert(pageBounds.top),
      left: convert(pageBounds.left),
      bottom: convert(pageBounds.bottom),
      right: convert(pageBounds.right),
    });
  }

  toPage(cellSizeInPixels: number): BoundingRectangle {
    return this.map(toPage(cellSizeInPixels));
  }
}
