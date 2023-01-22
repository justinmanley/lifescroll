import { LifeGridBoundingRectangle } from "../coordinates/bounding-rectangle";
import { LifeGridInterval } from "../coordinates/interval";
import { LifeGridVector2 } from "../coordinates/vector2";
import { StepCriterion, stepCriterionDecoder } from "./step-criterion";
import { Decoder, Functor, struct, intersect, partial } from "io-ts/Decoder";
import { Movement } from "./movement";
import { pipe } from "fp-ts/function";
import { BoundingRectangleEdgeMovements } from "./bounding-rectangle-edge-movements";

interface AtomicUpdateRegionParams {
  bounds: LifeGridBoundingRectangle;
  stepCriterion: StepCriterion;
  movement?: Movement;
  boundsEdgeMovements?: BoundingRectangleEdgeMovements;
}

export class AtomicUpdateRegion {
  constructor(
    private readonly params: AtomicUpdateRegionParams,
    private readonly stepsElapsed: number
  ) {}

  offset(position: LifeGridVector2): AtomicUpdateRegion {
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
        bounds: this.applyEdgeMovements(
          this.applyMovement(this.bounds, stepsElapsed),
          stepsElapsed
        ),
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

  private applyMovement(
    bounds: LifeGridBoundingRectangle,
    stepsElapsed: number
  ): LifeGridBoundingRectangle {
    const movement = this.params.movement;
    return movement && stepsElapsed % movement.period === 0
      ? bounds.offset(movement.direction)
      : bounds;
  }

  private applyEdgeMovements(
    bounds: LifeGridBoundingRectangle,
    steps: number
  ): LifeGridBoundingRectangle {
    const movements = this.params.boundsEdgeMovements;
    return new LifeGridBoundingRectangle({
      top: movements?.top?.move(bounds.top, steps) ?? bounds.top,
      left: movements?.left?.move(bounds.left, steps) ?? bounds.left,
      bottom: movements?.bottom?.move(bounds.bottom, steps) ?? bounds.bottom,
      right: movements?.right?.move(bounds.right, steps) ?? bounds.right,
    });
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
          boundsEdgeMovements: BoundingRectangleEdgeMovements.decoder,
        })
      )
    ),
    (params) => new AtomicUpdateRegion(params, 0)
  );
}
