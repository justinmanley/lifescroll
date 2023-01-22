import { LifeGridSize2 } from "../coordinates/size2";
import { AtomicUpdateRegion } from "./atomic-update-region";
import { Decoder, Functor, struct, array } from "io-ts/Decoder";

export class PatternRenderingOptions {
  constructor(
    // How much space to reserve on the page.
    private readonly _reserve: LifeGridSize2,
    public readonly atomicUpdateRegions: AtomicUpdateRegion[]
  ) {}

  static decoder: Decoder<unknown, PatternRenderingOptions> = Functor.map(
    struct({
      reserve: LifeGridSize2.decoder,
      atomicUpdateRegions: array(AtomicUpdateRegion.decoder),
    }),
    ({ reserve, atomicUpdateRegions }) =>
      new PatternRenderingOptions(reserve, atomicUpdateRegions)
  );

  get reserve(): LifeGridSize2 {
    return new LifeGridSize2(
      this._reserve.width,
      this._reserve.height + 2 * verticalPadding
    );
  }
}

const verticalPadding = 1;
