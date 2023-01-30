import { Interval } from "../math/geometry/interval";
import { Vector2 } from "../math/linear-algebra/vector2";
import { LifeGridBoundingRectangle } from "./coordinates/bounding-rectangle";
import { LifeGridVector2 } from "./coordinates/vector2";
import { AtomicUpdate } from "./pattern-rendering-options/atomic-update";
import { PatternRenderingOptions } from "./pattern-rendering-options/pattern-rendering-options";
import { Role } from "./pattern-rendering-options/role";

interface PatternLayoutParams {
  preferredHorizontalRange: Interval;
  cellSizeInPixels: number;
  anchorStart: Vector2;
}

export interface LaidOutPattern {
  id: string;
  cells: LifeGridVector2[];
  atomicUpdate: AtomicUpdate;
  role: Role;
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
      new Vector2(
        this.renderingOptions.role === Role.Pattern
          ? preferredHorizontalCenter
          : anchorStart.x,
        anchorStart.y
      ),
      layoutParams.cellSizeInPixels
    )
      .minus(focusRegion ? focusRegion.center() : gridBounds.center())
      .plus(new LifeGridVector2(0, Math.floor(reserved.height / 2)));

    return {
      id: this.id,
      cells: this.cells.map((position) => position.plus(gridStart)),
      atomicUpdate: this.renderingOptions.atomicUpdate.offset(gridStart),
      role: this.renderingOptions.role,
    };
  }
}
