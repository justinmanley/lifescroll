import { JsonMissingFieldError, JsonWrongTypeError } from "../../json/decoding";
import { Size2 } from "../../math/geometry/size2";
import { fromPage, toPage } from "./mappings";

export class LifeGridSize2 {
  constructor(public readonly width: number, public readonly height: number) {}

  static fromPage(pageSize2: Size2, cellSizeInPixels: number): LifeGridSize2 {
    const convert = fromPage(cellSizeInPixels);
    return new LifeGridSize2(
      convert(pageSize2.width),
      convert(pageSize2.height)
    );
  }

  toPage(cellSizeInPixels: number): Size2 {
    const convert = toPage(cellSizeInPixels);
    return new Size2(convert(this.width), convert(this.height));
  }

  map(fn: (value: number) => number): LifeGridSize2 {
    return new LifeGridSize2(fn(this.width), fn(this.height));
  }

  static decode(object: object): LifeGridSize2 {
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
    return new LifeGridSize2(object["width"], object["height"]);
  }
}
