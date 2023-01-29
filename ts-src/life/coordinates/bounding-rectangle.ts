import {
  BoundingRectangle,
  BoundingRectangleParams,
  BoundingRectangleParamsDecoder,
} from "../../math/geometry/bounding-rectangle";
import { LifeGridInterval } from "./interval";
import { fromPage, toPage } from "./mappings";
import { LifeGridVector2 } from "./vector2";
import { LifeGridSize2 } from "./size2";
import { Decoder, Functor } from "io-ts/Decoder";

export class LifeGridBoundingRectangle {
  public readonly width: number;
  public readonly height: number;

  constructor(private params: BoundingRectangleParams) {
    this.width = params.right - params.left;
    this.height = params.bottom - params.top;
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
    return new BoundingRectangle(this.params).map(toPage(cellSizeInPixels));
  }

  map(fn: (value: number) => number): LifeGridBoundingRectangle {
    return new LifeGridBoundingRectangle({
      top: fn(this.top),
      left: fn(this.left),
      bottom: fn(this.bottom),
      right: fn(this.right),
    });
  }

  horizontal(): LifeGridInterval {
    return new LifeGridInterval(this.left, this.right);
  }

  vertical(): LifeGridInterval {
    return new LifeGridInterval(this.top, this.bottom);
  }

  center(): LifeGridVector2 {
    return new LifeGridVector2(
      this.horizontal().center(),
      this.vertical().center()
    );
  }

  contains(other: LifeGridBoundingRectangle | LifeGridVector2): boolean {
    if (other instanceof LifeGridVector2) {
      return (
        this.vertical().contains(other.y) && this.horizontal().contains(other.x)
      );
    }

    return (
      this.vertical().contains(other.vertical()) &&
      this.horizontal().contains(other.horizontal())
    );
  }

  size(): LifeGridSize2 {
    return new LifeGridSize2(this.width, this.height);
  }

  get top() {
    return this.params.top;
  }

  get left() {
    return this.params.left;
  }

  get bottom() {
    return this.params.bottom;
  }

  get right() {
    return this.params.right;
  }

  start(): LifeGridVector2 {
    return new LifeGridVector2(this.left, this.top);
  }

  offset(amount: LifeGridVector2): LifeGridBoundingRectangle {
    return new LifeGridBoundingRectangle({
      top: this.top + amount.y,
      left: this.left + amount.x,
      bottom: this.bottom + amount.y,
      right: this.right + amount.x,
    });
  }

  static enclosing(positions: LifeGridVector2[]): LifeGridBoundingRectangle {
    return new LifeGridBoundingRectangle({
      top: Math.min(...positions.map((p) => p.y)),
      left: Math.min(...positions.map((p) => p.x)),
      bottom: Math.max(...positions.map((p) => p.y)) + 1,
      right: Math.max(...positions.map((p) => p.x)) + 1,
    });
  }

  static decoder: Decoder<unknown, LifeGridBoundingRectangle> = Functor.map(
    BoundingRectangleParamsDecoder,
    (params) => new LifeGridBoundingRectangle(params)
  );
}
