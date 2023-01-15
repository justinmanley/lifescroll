import { Size2 } from "../../math/geometry/size2";
import { JsonMissingFieldError, JsonWrongTypeError } from "../../json/decoding";
import { LifeGridSize2 } from "../coordinates/size2";

export class PatternRenderingOptions {
  constructor(
    // How much space to reserve on the page.
    public readonly reserve: LifeGridSize2
  ) {}

  static decode(object: object): PatternRenderingOptions {
    if (!("reserve" in object)) {
      throw new JsonMissingFieldError(object, "reserve");
    }
    if (typeof object["reserve"] !== "object" || object["reserve"] === null) {
      throw new JsonWrongTypeError(object["reserve"], "object");
    }
    return new PatternRenderingOptions(LifeGridSize2.decode(object["reserve"]));
  }
}
