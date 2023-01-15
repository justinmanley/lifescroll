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
    const layoutEngine = new PatternLayoutEngine(
      this.cells,
      this.renderingOptions,
      layoutParams
    );

    return {
      id: this.id,
      cells: layoutEngine.layoutCells(),
    };
  }
}

export class PatternLayoutEngine {
  private gridStart: LifeGridPosition;

  constructor(
    private readonly positions: LifeGridPosition[],
    private readonly renderingOptions: PatternRenderingOptions,
    private readonly layoutParams: PatternLayoutParams
  ) {
    this.gridStart =
      this.topLeftPositionToAlignWithPatternAnchorTopAndCenterHorizontally();
  }

  layoutCells(): LifeGridPosition[] {
    return this.positions.map((position) => this.layoutCell(position));
  }

  private layoutCell(position: LifeGridPosition): LifeGridPosition {
    return position.plus(this.gridStart);
  }

  private topLeftPositionToAlignWithPatternAnchorTopAndCenterHorizontally(): LifeGridPosition {
    const preferredHorizontalCenter =
      this.layoutParams.preferredHorizontalRange.center();
    const gridBounds = LifeGridBoundingRectangle.enclosing(this.positions);

    const reserved = this.renderingOptions.reserve;
    const anchorStart = this.layoutParams.anchorStart;

    return LifeGridPosition.fromPage(
      new Vector2(preferredHorizontalCenter, anchorStart.y),
      this.layoutParams.cellSizeInPixels
    )
      .minus(gridBounds.center())
      .plus(new LifeGridPosition(0, Math.floor(reserved.height / 2)));
  }
}
