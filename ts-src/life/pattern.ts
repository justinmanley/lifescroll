import { Interval } from "../math/geometry/interval";
import { Vector2 } from "../math/linear-algebra/vector2";
import { LifeGridBoundingRectangle } from "./coordinates/bounding-rectangle";
import { LifeGridVector2 } from "./coordinates/vector2";
import { AtomicUpdateRegion } from "./pattern-rendering-options/atomic-update-region";
import { PatternRenderingOptions } from "./pattern-rendering-options/pattern-rendering-options";

interface PatternLayoutParams {
  preferredHorizontalRange: Interval;
  cellSizeInPixels: number;
  anchorStart: Vector2;
}

export interface LaidOutPattern {
  id: string;
  cells: LifeGridVector2[];
  atomicUpdateRegions: AtomicUpdateRegion[];
}

export class Pattern {
  constructor(
    public readonly id: string,
    private readonly cells: LifeGridVector2[],
    private readonly renderingOptions: PatternRenderingOptions
  ) {}

  layout(layoutParams: PatternLayoutParams): LaidOutPattern {
    const preferredHorizontalCenter =
      layoutParams.preferredHorizontalRange.center();
    const gridBounds = LifeGridBoundingRectangle.enclosing(this.cells);

    const reserved = this.renderingOptions.reserve;
    const anchorStart = layoutParams.anchorStart;
    const focusRegion = this.renderingOptions.focusRegion;

    const gridStart = LifeGridVector2.fromPage(
      new Vector2(preferredHorizontalCenter, anchorStart.y),
      layoutParams.cellSizeInPixels
    )
      .minus(focusRegion ? focusRegion.center() : gridBounds.center())
      .plus(new LifeGridVector2(0, Math.floor(reserved.height / 2)));

    return {
      id: this.id,
      cells: this.cells.map((position) => position.plus(gridStart)),
      atomicUpdateRegions: this.renderingOptions.atomicUpdateRegions.map(
        (atomicUpdateRegion) => atomicUpdateRegion.offset(gridStart)
      ),
    };
  }
}
