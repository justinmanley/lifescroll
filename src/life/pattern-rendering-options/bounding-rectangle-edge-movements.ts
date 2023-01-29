import { Decoder, Functor, partial, struct, number } from "io-ts/Decoder";

interface BoundingRectangleEdgeMovementsParams {
  top?: EdgeMovement;
  left?: EdgeMovement;
  bottom?: EdgeMovement;
  right?: EdgeMovement;
}

class EdgeMovement {
  constructor(
    public readonly direction: number,
    public readonly period: number
  ) {}

  move(edge: number, stepsElapsed: number): number {
    return stepsElapsed % this.period === 0 ? edge + this.direction : edge;
  }

  static decoder: Decoder<unknown, EdgeMovement> = Functor.map(
    struct({
      direction: number,
      period: number,
    }),
    ({ direction, period }) => new EdgeMovement(direction, period)
  );
}

export class BoundingRectangleEdgeMovements {
  constructor(private readonly params: BoundingRectangleEdgeMovementsParams) {}

  get top(): EdgeMovement | undefined {
    return this.params.top;
  }

  get left(): EdgeMovement | undefined {
    return this.params.left;
  }

  get bottom(): EdgeMovement | undefined {
    return this.params.bottom;
  }

  get right(): EdgeMovement | undefined {
    return this.params.right;
  }

  static decoder: Decoder<unknown, BoundingRectangleEdgeMovements> =
    Functor.map(
      partial({
        top: EdgeMovement.decoder,
        left: EdgeMovement.decoder,
        bottom: EdgeMovement.decoder,
        right: EdgeMovement.decoder,
      }),
      (params) => new BoundingRectangleEdgeMovements(params)
    );
}
