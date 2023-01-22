import { LifeGridPosition } from "../coordinates/position";
import { Decoder, Functor, struct, number } from "io-ts/Decoder";

export class Movement {
  constructor(
    public readonly direction: LifeGridPosition,
    public readonly period: number
  ) {}

  static decoder: Decoder<unknown, Movement> = Functor.map(
    struct({
      direction: LifeGridPosition.decoder,
      period: number,
    }),
    ({ direction, period }) => new Movement(direction, period)
  );
}
