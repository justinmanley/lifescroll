import { Interval } from "../math/geometry/interval";
import { Vector2 } from "../math/linear-algebra/vector2";
import { LifeGridBoundingRectangle } from "./coordinates/bounding-rectangle";
import { LifeGridPosition } from "./coordinates/position";
import { PatternRenderingOptions } from "./pattern-rendering-options/pattern-rendering-options";

interface PatternLayoutParams {
  preferredHorizontalRange: Interval;
  cellSizeInPixels: number;
  anchorStart: Vector2;
}

export interface LaidOutPattern {
  id: string;
  cells: LifeGridPosition[];
}

export class Pattern {
  constructor(
    public readonly id: string,
    private readonly cells: LifeGridPosition[],
    private readonly renderingOptions: PatternRenderingOptions
  ) {}

  layout(layoutParams: PatternLayoutParams): LaidOutPattern {
    const preferredHorizontalCenter =
      layoutParams.preferredHorizontalRange.center();
    const gridBounds = LifeGridBoundingRectangle.enclosing(this.cells);

    const reserved = this.renderingOptions.reserve;
    const anchorStart = layoutParams.anchorStart;

    const gridStart = LifeGridPosition.fromPage(
      new Vector2(preferredHorizontalCenter, anchorStart.y),
      layoutParams.cellSizeInPixels
    )
      .minus(gridBounds.center())
      .plus(new LifeGridPosition(0, Math.floor(reserved.height / 2)));

    return {
      id: this.id,
      cells: this.cells.map((position) => position.plus(gridStart)),
    };
  }
}
