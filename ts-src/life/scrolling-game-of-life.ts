import { BoundingRectangle } from "../math/geometry/bounding-rectangle";
import { Cells } from "./cells";
import { LifeGridBoundingRectangle } from "./coordinates/bounding-rectangle";
import { LifeGridPosition } from "./coordinates/position";
import { LaidOutPattern } from "./pattern";
import { GameOfLife } from "./game-of-life";

export interface LayoutParams {
  full: BoundingRectangle;
  center: BoundingRectangle;
  cellSizeInPixels: number;
}

export class ScrollingGameOfLife {
  private cells: Cells;
  private rule: GameOfLife;

  constructor(patterns: LaidOutPattern[]) {
    this.cells = new Cells(
      ([] as LifeGridPosition[]).concat(
        ...patterns.map((pattern) => pattern.cells)
      )
    );
    this.rule = new GameOfLife();
  }

  public scroll(viewport: LifeGridBoundingRectangle): Cells {
    const { inside, outside } = this.cells.partition(viewport);
    if (inside.length === 0) {
      return this.cells;
    }

    this.cells = new Cells([...this.rule.next(inside), ...outside]);

    return this.cells;
  }
}
