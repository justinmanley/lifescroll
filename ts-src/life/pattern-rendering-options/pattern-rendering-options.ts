import { JsonMissingFieldError, JsonWrongTypeError } from "../../json/decoding";
import { LifeGridSize2 } from "../coordinates/size2";
import { AtomicUpdateRegion } from "./atomic-update-region";

export class PatternRenderingOptions {
  constructor(
    // How much space to reserve on the page.
    private readonly _reserve: LifeGridSize2,
    public readonly atomicUpdateRegions: AtomicUpdateRegion[]
  ) {}

  static decode(object: object): PatternRenderingOptions {
    if (!("reserve" in object)) {
      throw new JsonMissingFieldError(object, "reserve");
    }
    const reserveObject = object["reserve"];
    if (typeof reserveObject !== "object" || reserveObject === null) {
      throw new JsonWrongTypeError(reserveObject, "object");
    }

    if (!("atomicUpdateRegions" in object)) {
      throw new JsonMissingFieldError(object, "atomicUpdateRegions");
    }
    const atomicUpdateRegionsObject = object["atomicUpdateRegions"];
    if (!Array.isArray(atomicUpdateRegionsObject)) {
      throw new JsonWrongTypeError(atomicUpdateRegionsObject, "object");
    }

    return new PatternRenderingOptions(
      LifeGridSize2.decode(reserveObject),
      atomicUpdateRegionsObject.map(AtomicUpdateRegion.decode)
    );
  }

  get reserve(): LifeGridSize2 {
    return new LifeGridSize2(
      this._reserve.width,
      this._reserve.height + 2 * verticalPadding
    );
  }
}

const verticalPadding = 1;
