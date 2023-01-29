import { LifeGridBoundingRectangle } from "../coordinates/bounding-rectangle";
import { LifeGridInterval } from "../coordinates/interval";
import { LifeGridVector2 } from "../coordinates/vector2";
import { StepCriterion, stepCriterionDecoder } from "./step-criterion";
import { Decoder, Functor, struct, array } from "io-ts/Decoder";
import { AtomicUpdateRegion } from "./atomic-update-region";

interface AtomicUpdateParams {
  regions: AtomicUpdateRegion[];
  stepCriterion: StepCriterion;
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

  static decoder: Decoder<unknown, AtomicUpdate> = Functor.map(
    struct({
      regions: array(AtomicUpdateRegion.decoder),
      stepCriterion: stepCriterionDecoder,
    }),
    (params) => new AtomicUpdate(params, 0)
  );
}
