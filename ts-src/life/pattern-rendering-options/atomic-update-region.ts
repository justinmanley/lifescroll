import { JsonMissingFieldError, JsonWrongTypeError } from "../../json/decoding";
import { LifeGridBoundingRectangle } from "../coordinates/bounding-rectangle";
import { LifeGridInterval } from "../coordinates/interval";
import { LifeGridPosition } from "../coordinates/position";
import { decodeStepCriterion, StepCriterion } from "./step-criterion";

export class AtomicUpdateRegion {
  constructor(
    public readonly bounds: LifeGridBoundingRectangle,
    public readonly stepCriterion: StepCriterion
  ) {}

  offset(position: LifeGridPosition): AtomicUpdateRegion {
    return new AtomicUpdateRegion(
      this.bounds.offset(position),
      this.stepCriterion
    );
  }

  isSteppable(viewportVerticalBounds: LifeGridInterval): boolean {
    switch (this.stepCriterion) {
      case StepCriterion.AnyIntersectionWithSteppableRegion:
        return this.bounds.vertical().intersects(viewportVerticalBounds);
      case StepCriterion.FullyContainedWithinSteppableRegion:
        return viewportVerticalBounds.contains(this.bounds.vertical());
    }
  }

  next() {}

  static decode(object: object): AtomicUpdateRegion {
    if (!("bounds" in object)) {
      throw new JsonMissingFieldError(object, "bounds");
    }
    const boundsObject = object["bounds"];
    if (typeof boundsObject !== "object" || boundsObject === null) {
      throw new JsonWrongTypeError(boundsObject, "object");
    }
    const bounds = LifeGridBoundingRectangle.decode(boundsObject);

    if (!("stepCriterion" in object)) {
      throw new JsonMissingFieldError(object, "stepCriterion");
    }
    const stepCriterionString = object["stepCriterion"];
    if (typeof stepCriterionString !== "string") {
      throw new Error(`Expected step criterion to be a string`);
    }
    const stepCriterion = decodeStepCriterion(stepCriterionString);

    return new AtomicUpdateRegion(bounds, stepCriterion);
  }
}
