import { JsonMissingFieldError, JsonWrongTypeError } from "../../json/decoding";
import { Vector2 } from "../linear-algebra/vector2";
import { Interval } from "./interval";

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

export const decodeBoundingRectangleParams = (
  object: object
): BoundingRectangleParams => {
  if (!("top" in object)) {
    throw new JsonMissingFieldError(object, "top");
  }
  const top = object["top"];
  if (typeof top !== "number") {
    throw new JsonWrongTypeError(top, "number");
  }
  if (!("left" in object)) {
    throw new JsonMissingFieldError(object, "left");
  }
  const left = object["left"];
  if (typeof left !== "number") {
    throw new JsonWrongTypeError(left, "number");
  }
  if (!("bottom" in object)) {
    throw new JsonMissingFieldError(object, "bottom");
  }
  const bottom = object["bottom"];
  if (typeof bottom !== "number") {
    throw new JsonWrongTypeError(bottom, "number");
  }
  if (!("right" in object)) {
    throw new JsonMissingFieldError(object, "right");
  }
  const right = object["right"];
  if (typeof right !== "number") {
    throw new JsonWrongTypeError(right, "number");
  }
  return { top, left, bottom, right };
};
