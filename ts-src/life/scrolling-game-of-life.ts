import { BoundingRectangle } from "../math/geometry/bounding-rectangle";
import { Cells } from "./cells";
import { DebugSettings } from "./debug-settings";
import { Pattern } from "./pattern";

export interface LayoutParams {
  full: BoundingRectangle;
  center: BoundingRectangle;
  cellSizeInPixels: number;
}

export class ScrollingGameOfLife {
  private debug = new DebugSettings();

  private cells = new Cells([]);

  constructor(
    private readonly patterns: Pattern[],
    private readonly layout: LayoutParams
  ) {}

  public scroll(viewport: BoundingRectangle): Cells {
    return this.cells;
  }
}
