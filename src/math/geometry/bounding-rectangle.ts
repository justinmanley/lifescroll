import { JsonMissingFieldError, JsonWrongTypeError } from "../../json/decoding";
import { Vector2 } from "../linear-algebra/vector2";
import { Interval } from "./interval";
import { Decoder, number, struct } from "io-ts/Decoder";

export interface BoundingRectangleParams {
  top: number;
  left: number;
  bottom: number;
  right: number;
}

export class BoundingRectangle {
  public readonly width: number;
  public readonly height: number;

  constructor(private params: BoundingRectangleParams) {
    this.width = params.right - params.left;
    this.height = params.bottom - params.top;
  }

  static empty(): BoundingRectangle {
    return new BoundingRectangle({
      top: 0,
      left: 0,
      bottom: 0,
      right: 0,
    });
  }

  map(fn: (value: number) => number): BoundingRectangle {
    return new BoundingRectangle({
      top: fn(this.top),
      left: fn(this.left),
      bottom: fn(this.bottom),
      right: fn(this.right),
    });
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

  start(): Vector2 {
    return new Vector2(this.left, this.top);
  }

  vertical(): Interval {
    return new Interval(this.top, this.bottom);
  }

  horizontal(): Interval {
    return new Interval(this.left, this.right);
  }
}

export const BoundingRectangleParamsDecoder: Decoder<
  unknown,
  BoundingRectangleParams
> = struct({
  top: number,
  left: number,
  bottom: number,
  right: number,
});
