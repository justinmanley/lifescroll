import { JsonMissingFieldError, JsonWrongTypeError } from "../../json/decoding";
import { Vector2 } from "../linear-algebra/vector2";

export class Size2 extends Vector2 {
  constructor(public readonly width: number, public readonly height: number) {
    super(width, height);
  }

  static decode(object: object): Size2 {
    if (!("width" in object)) {
      throw new JsonMissingFieldError(object, "width");
    }
    if (!(typeof object["width"] === "number")) {
      throw new JsonWrongTypeError(object["width"], "number");
    }
    if (!("height" in object)) {
      throw new JsonMissingFieldError(object, "height");
    }
    if (!(typeof object["height"] === "number")) {
      throw new JsonWrongTypeError(object["height"], "number");
    }
    return new Size2(object["width"], object["height"]);
  }
}
