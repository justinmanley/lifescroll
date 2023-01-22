import { LifeGridBoundingRectangle } from "../coordinates/bounding-rectangle";
import { LifeGridInterval } from "../coordinates/interval";
import { LifeGridPosition } from "../coordinates/position";
import { StepCriterion, stepCriterionDecoder } from "./step-criterion";
import { Decoder, Functor, struct } from "io-ts/Decoder";

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

  static decoder: Decoder<unknown, AtomicUpdateRegion> = Functor.map(
    struct({
      bounds: LifeGridBoundingRectangle.decoder,
      stepCriterion: stepCriterionDecoder,
    }),
    ({ bounds, stepCriterion }) => new AtomicUpdateRegion(bounds, stepCriterion)
  );
}
