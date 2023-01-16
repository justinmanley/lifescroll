import { BoundingRectangle } from "../math/geometry/bounding-rectangle";
import { Cells } from "./cells";
import { LifeGridPosition } from "./coordinates/position";
import { DebugSettings } from "./debug-settings";
import { LaidOutPattern, Pattern } from "./pattern";

export interface LayoutParams {
  full: BoundingRectangle;
  center: BoundingRectangle;
  cellSizeInPixels: number;
}

export class ScrollingGameOfLife {
  private cells: Cells;

  constructor(
    patterns: LaidOutPattern[],
    private readonly layout: LayoutParams
  ) {
    this.cells = new Cells(
      ([] as LifeGridPosition[]).concat(
        ...patterns.map((pattern) => pattern.cells)
      )
    );
  }

  public scroll(viewport: BoundingRectangle): Cells {
    return this.cells;
  }
}
