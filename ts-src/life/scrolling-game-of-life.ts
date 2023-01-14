import { BoundingRectangle } from "../math/geometry/bounding-rectangle";
import { DebugSettings } from "./debug-settings";
import { Pattern } from "./pattern";

export interface LayoutParams {
  full: BoundingRectangle;
  center: BoundingRectangle;
  cellSizeInPixels: number;
}

export class ScrollingGameOfLife {
  private debug = new DebugSettings();

  constructor(
    private readonly patterns: Pattern[],
    private readonly layout: LayoutParams
  ) {}

  public onScroll(viewport: BoundingRectangle) {}
}
