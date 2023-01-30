import { LifeGridSize2 } from "../coordinates/size2";
import { AtomicUpdate } from "./atomic-update";
import { Decoder, Functor, struct, intersect, partial } from "io-ts/Decoder";
import { LifeGridBoundingRectangle } from "../coordinates/bounding-rectangle";
import { pipe } from "fp-ts/function";
import { Role, roleDecoder } from "./role";

interface PatternRenderingOptionsParams {
  // How much space to reserve on the page.
  reserve: LifeGridSize2;
  atomicUpdate: AtomicUpdate;
  focusRegion?: LifeGridBoundingRectangle;
  role: Role;
}

export class PatternRenderingOptions {
  constructor(private params: PatternRenderingOptionsParams) {}

  static decoder: Decoder<unknown, PatternRenderingOptions> = Functor.map(
    pipe(
      struct({
        reserve: LifeGridSize2.decoder,
        atomicUpdate: AtomicUpdate.decoder,
      }),
      intersect(
        partial({
          focusRegion: LifeGridBoundingRectangle.decoder,
          role: roleDecoder,
        })
      )
    ),
    (params) =>
      new PatternRenderingOptions({
        ...params,
        role: params.role ?? Role.Pattern,
      })
  );

  get reserve(): LifeGridSize2 {
    return new LifeGridSize2(
      this.params.reserve.width,
      this.role === Role.Pattern
        ? this.params.reserve.height + 2 * verticalPadding
        : this.params.reserve.height
    );
  }

  get atomicUpdate(): AtomicUpdate {
    return this.params.atomicUpdate;
  }

  get focusRegion(): LifeGridBoundingRectangle | undefined {
    return this.params.focusRegion;
  }

  get role(): Role {
    return this.params.role;
  }
}

const verticalPadding = 1;
