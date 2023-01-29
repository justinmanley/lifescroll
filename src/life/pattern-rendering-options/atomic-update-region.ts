import { LifeGridBoundingRectangle } from "../coordinates/bounding-rectangle";
import { LifeGridVector2 } from "../coordinates/vector2";
import { AtomicUpdateBounds } from "./atomic-update-bounds";
import { BoundingRectangleEdgeMovements } from "./bounding-rectangle-edge-movements";
import { Movement } from "./movement";
import { pipe } from "fp-ts/function";
import {
  Decoder,
  Functor,
  struct,
  intersect,
  partial,
  number,
} from "io-ts/Decoder";

interface AtomicUpdateRegionParams {
  source: LifeGridBoundingRectangle;
  movement?: Movement;
  boundsEdgeMovements?: BoundingRectangleEdgeMovements;
  generate?: { period: number };
  bounds?: AtomicUpdateBounds[];
}

export class AtomicUpdateRegion {
  private bounds: AtomicUpdateBounds[];

  constructor(private readonly params: AtomicUpdateRegionParams) {
    this.bounds = params.bounds ?? [new AtomicUpdateBounds(params.source)];
  }

  offset(position: LifeGridVector2): AtomicUpdateRegion {
    const bounds = this.params.source;
    return new AtomicUpdateRegion({
      ...this.params,
      source: bounds.offset(position),
    });
  }

  next(stepsElapsed: number): AtomicUpdateRegion {
    const existing = this.bounds.map((bounds) =>
      bounds.next({
        stepsElapsed,
        movement: this.params.movement,
        edgeMovements: this.params.boundsEdgeMovements,
      })
    );

    return new AtomicUpdateRegion({
      ...this.params,
      bounds: this.shouldGenerate(stepsElapsed)
        ? existing.concat(this.generate())
        : existing,
    });
  }

  get rectangles(): LifeGridBoundingRectangle[] {
    return this.bounds.map((bounds) => bounds.rectangle);
  }

  static decoder: Decoder<unknown, AtomicUpdateRegion> = Functor.map(
    pipe(
      struct({
        bounds: LifeGridBoundingRectangle.decoder,
      }),
      intersect(
        partial({
          movement: Movement.decoder,
          boundsEdgeMovements: BoundingRectangleEdgeMovements.decoder,
          generate: struct({
            period: number,
          }),
        })
      )
    ),
    ({ bounds, movement, boundsEdgeMovements, generate }) =>
      new AtomicUpdateRegion({
        source: bounds,
        movement: movement,
        boundsEdgeMovements: boundsEdgeMovements,
        generate: generate,
      })
  );

  private shouldGenerate(stepsElapsed: number): boolean {
    if (!this.params.generate) {
      return false;
    }
    return stepsElapsed % this.params.generate.period === 0;
  }

  private generate(): AtomicUpdateBounds {
    return new AtomicUpdateBounds(this.params.source);
  }
}
