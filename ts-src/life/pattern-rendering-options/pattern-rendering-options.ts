import { Size2 } from "../../math/geometry/size2";
import { JsonMissingFieldError, JsonWrongTypeError } from "../../json/decoding";

export class PatternRenderingOptions {
  constructor(
    // How much space to reserve on the page.
    public readonly reserve: Size2
  ) {}

  static decode(object: object): PatternRenderingOptions {
    if (!("reserve" in object)) {
      throw new JsonMissingFieldError(object, "reserve");
    }
    if (typeof object["reserve"] !== "object" || object["reserve"] === null) {
      throw new JsonWrongTypeError(object["reserve"], "object");
    }
    return new PatternRenderingOptions(Size2.decode(object["reserve"]));
  }
}
