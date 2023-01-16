import { JsonMissingFieldError, JsonWrongTypeError } from "../../json/decoding";
import { LifeGridSize2 } from "../coordinates/size2";

export class PatternRenderingOptions {
  constructor(
    // How much space to reserve on the page.
    private readonly _reserve: LifeGridSize2
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

  get reserve(): LifeGridSize2 {
    return new LifeGridSize2(
      this._reserve.width,
      this._reserve.height + 2 * verticalPadding
    );
  }
}

const verticalPadding = 1;
