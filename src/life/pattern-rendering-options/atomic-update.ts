import { LifeGridBoundingRectangle } from "../coordinates/bounding-rectangle";
import { LifeGridInterval } from "../coordinates/interval";
import { LifeGridVector2 } from "../coordinates/vector2";
import { StepCriterion, stepCriterionDecoder } from "./step-criterion";
import {
  Decoder,
  Functor,
  struct,
  array,
  intersect,
  partial,
  number,
} from "io-ts/Decoder";
import { pipe } from "fp-ts/function";
import { AtomicUpdateRegion } from "./atomic-update-region";

interface AtomicUpdateParams {
  regions: AtomicUpdateRegion[];
  stepCriterion: StepCriterion;
  // May be a set to a number in [0, 1] representing a vertical position
  // within the viewport (0 corresponds to the top, 1 to the bottom).
  delayUntilAboveViewportRatio?: number;
}

export class AtomicUpdate {
  constructor(
    private readonly params: AtomicUpdateParams,
    private readonly stepsElapsed: number
  ) {}

  offset(position: LifeGridVector2): AtomicUpdate {
    return new AtomicUpdate(
      {
        ...this.params,
        regions: this.regions.map((region) => region.offset(position)),
      },
      this.stepsElapsed
    );
  }

  isSteppable(viewportVerticalBounds: LifeGridInterval): boolean {
    return (
      this.hasDelayElapsed(viewportVerticalBounds) &&
      this.isSteppableAfterDelay(viewportVerticalBounds)
    );
  }

  isSteppableAfterDelay(viewportVerticalBounds: LifeGridInterval): boolean {
    switch (this.stepCriterion) {
      case StepCriterion.AnyIntersectionWithSteppableRegion:
        return this.bounds.some((bounds) =>
          bounds.vertical().intersects(viewportVerticalBounds)
        );
      case StepCriterion.FullyContainedWithinSteppableRegion:
        return this.bounds.every((bounds) =>
          viewportVerticalBounds.contains(bounds.vertical())
        );
    }
  }

  next(): AtomicUpdate {
    const stepsElapsed = this.stepsElapsed + 1;
    return new AtomicUpdate(
      {
        ...this.params,
        regions: this.regions.map((region) => region.next(stepsElapsed)),
      },
      stepsElapsed
    );
  }

  get bounds(): LifeGridBoundingRectangle[] {
    return this.regions.flatMap((region) => region.rectangles);
  }

  get regions(): AtomicUpdateRegion[] {
    return this.params.regions;
  }

  get stepCriterion(): StepCriterion {
    return this.params.stepCriterion;
  }

  private hasDelayElapsed(viewportVerticalBounds: LifeGridInterval): boolean {
    const delayUntilAboveViewport = this.params.delayUntilAboveViewportRatio;
    if (delayUntilAboveViewport === undefined) {
      // No delay.
      return true;
    }

    if (this.stepsElapsed > 0) {
      return true;
    }

    const viewportThreshold = viewportVerticalBounds.interpolate(
      delayUntilAboveViewport
    );

    switch (this.stepCriterion) {
      case StepCriterion.AnyIntersectionWithSteppableRegion:
        return this.bounds.some((bounds) => bounds.top < viewportThreshold);
      case StepCriterion.FullyContainedWithinSteppableRegion:
        return this.bounds.every((bounds) => bounds.bottom < viewportThreshold);
    }
  }

  static decoder: Decoder<unknown, AtomicUpdate> = Functor.map(
    pipe(
      struct({
        regions: array(AtomicUpdateRegion.decoder),
        stepCriterion: stepCriterionDecoder,
      }),
      intersect(
        partial({
          delayUntilAboveViewportRatio: number,
        })
      )
    ),
    (params) => new AtomicUpdate(params, 0)
  );
}
