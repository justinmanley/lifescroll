import { LifeGridSize2 } from "../coordinates/size2";
import { AtomicUpdateRegion } from "./atomic-update-region";
import {
  Decoder,
  Functor,
  struct,
  array,
  intersect,
  partial,
} from "io-ts/Decoder";
import { LifeGridBoundingRectangle } from "../coordinates/bounding-rectangle";
import { pipe } from "fp-ts/function";

interface PatternRenderingOptionsParams {
  // How much space to reserve on the page.
  reserve: LifeGridSize2;
  atomicUpdateRegions: AtomicUpdateRegion[];
  focusRegion?: LifeGridBoundingRectangle;
}

export class PatternRenderingOptions {
  constructor(private params: PatternRenderingOptionsParams) {}

  static decoder: Decoder<unknown, PatternRenderingOptions> = Functor.map(
    pipe(
      struct({
        reserve: LifeGridSize2.decoder,
        atomicUpdateRegions: array(AtomicUpdateRegion.decoder),
      }),
      intersect(
        partial({
          focusRegion: LifeGridBoundingRectangle.decoder,
        })
      )
    ),
    (params) => new PatternRenderingOptions(params)
  );

  get reserve(): LifeGridSize2 {
    return new LifeGridSize2(
      this.params.reserve.width,
      this.params.reserve.height + 2 * verticalPadding
    );
  }

  get atomicUpdateRegions(): AtomicUpdateRegion[] {
    return this.params.atomicUpdateRegions;
  }

  get focusRegion(): LifeGridBoundingRectangle | undefined {
    return this.params.focusRegion;
  }
}

const verticalPadding = 1;
