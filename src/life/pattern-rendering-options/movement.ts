import { LifeGridVector2 } from "../coordinates/vector2";
import { Decoder, Functor, struct, number } from "io-ts/Decoder";

export class Movement {
  constructor(
    public readonly direction: LifeGridVector2,
    public readonly period: number
  ) {}

  static decoder: Decoder<unknown, Movement> = Functor.map(
    struct({
      direction: LifeGridVector2.decoder,
      period: number,
    }),
    ({ direction, period }) => new Movement(direction, period)
  );
}
