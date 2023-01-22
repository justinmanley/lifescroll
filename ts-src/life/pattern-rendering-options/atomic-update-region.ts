import { LifeGridBoundingRectangle } from "../coordinates/bounding-rectangle";
import { LifeGridInterval } from "../coordinates/interval";
import { LifeGridPosition } from "../coordinates/position";
import { StepCriterion, stepCriterionDecoder } from "./step-criterion";
import { Decoder, Functor, struct, intersect, partial } from "io-ts/Decoder";
import { Movement } from "./movement";
import { pipe } from "fp-ts/function";

interface AtomicUpdateRegionParams {
  bounds: LifeGridBoundingRectangle;
  stepCriterion: StepCriterion;
  movement?: Movement;
}

export class AtomicUpdateRegion {
  constructor(
    private readonly params: AtomicUpdateRegionParams,
    private readonly stepsElapsed: number
  ) {}

  offset(position: LifeGridPosition): AtomicUpdateRegion {
    return new AtomicUpdateRegion(
      {
        ...this.params,
        bounds: this.bounds.offset(position),
      },
      this.stepsElapsed
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

  next(): AtomicUpdateRegion {
    const stepsElapsed = this.stepsElapsed + 1;
    return new AtomicUpdateRegion(
      {
        ...this.params,
        bounds: this.movedBounds(stepsElapsed),
      },
      stepsElapsed
    );
  }

  get bounds(): LifeGridBoundingRectangle {
    return this.params.bounds;
  }

  get stepCriterion(): StepCriterion {
    return this.params.stepCriterion;
  }

  private movedBounds(stepsElapsed: number): LifeGridBoundingRectangle {
    const movement = this.params.movement;
    console.log("calculating bounds movement", stepsElapsed, movement?.period);
    return movement && stepsElapsed % movement.period === 0
      ? this.bounds.offset(movement.direction)
      : this.bounds;
  }

  static decoder: Decoder<unknown, AtomicUpdateRegion> = Functor.map(
    pipe(
      struct({
        bounds: LifeGridBoundingRectangle.decoder,
        stepCriterion: stepCriterionDecoder,
      }),
      intersect(
        partial({
          movement: Movement.decoder,
        })
      )
    ),
    (params) => new AtomicUpdateRegion(params, 0)
  );
}
