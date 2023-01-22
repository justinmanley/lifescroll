import { JsonMissingFieldError, JsonWrongTypeError } from "../../json/decoding";
import { LifeGridBoundingRectangle } from "../coordinates/bounding-rectangle";
import { LifeGridPosition } from "../coordinates/position";

export class AtomicUpdateRegion {
  constructor(public readonly bounds: LifeGridBoundingRectangle) {}

  offset(position: LifeGridPosition): AtomicUpdateRegion {
    return new AtomicUpdateRegion(this.bounds.offset(position));
  }

  static decode(object: object): AtomicUpdateRegion {
    if (!("bounds" in object)) {
      throw new JsonMissingFieldError(object, "bounds");
    }
    const boundsObject = object["bounds"];
    if (typeof boundsObject !== "object" || boundsObject === null) {
      throw new JsonWrongTypeError(boundsObject, "object");
    }
    const bounds = LifeGridBoundingRectangle.decode(boundsObject);

    return new AtomicUpdateRegion(bounds);
  }
}
