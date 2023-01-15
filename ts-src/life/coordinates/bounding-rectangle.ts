import {
  BoundingRectangle,
  BoundingRectangleParams,
} from "../../math/geometry/bounding-rectangle";
import { LifeGridInterval } from "./interval";
import { fromPage, toPage } from "./mappings";
import { LifeGridPosition } from "./position";

export class LifeGridBoundingRectangle extends BoundingRectangle {
  constructor(params: BoundingRectangleParams) {
    super(params);
  }

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

  horizontal(): LifeGridInterval {
    return new LifeGridInterval(this.left, this.right);
  }

  vertical(): LifeGridInterval {
    return new LifeGridInterval(this.top, this.bottom);
  }

  center(): LifeGridPosition {
    return new LifeGridPosition(
      this.horizontal().center(),
      this.vertical().center()
    );
  }

  static enclosing(positions: LifeGridPosition[]): LifeGridBoundingRectangle {
    return new LifeGridBoundingRectangle({
      top: Math.min(...positions.map((p) => p.y)),
      left: Math.min(...positions.map((p) => p.x)),
      bottom: Math.max(...positions.map((p) => p.y)),
      right: Math.max(...positions.map((p) => p.x)),
    });
  }
}
