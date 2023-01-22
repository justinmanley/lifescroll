import { BoundingRectangle } from "../math/geometry/bounding-rectangle";
import { Cells } from "./cells";
import { LifeGridBoundingRectangle } from "./coordinates/bounding-rectangle";
import { LifeGridPosition } from "./coordinates/position";
import { LaidOutPattern } from "./pattern";
import { GameOfLife } from "./game-of-life";
import { AtomicUpdateRegion } from "./pattern-rendering-options/atomic-update-region";

export interface LayoutParams {
  full: BoundingRectangle;
  center: BoundingRectangle;
  cellSizeInPixels: number;
}

export interface LifeState {
  cells: Cells;
  atomicUpdateRegions: AtomicUpdateRegion[];
}

export class ScrollingGameOfLife {
  private cells: Cells;
  private atomicUpdateRegions: AtomicUpdateRegion[];
  private rule: GameOfLife;

  constructor(patterns: LaidOutPattern[]) {
    this.cells = new Cells(
      ([] as LifeGridPosition[]).concat(
        ...patterns.map((pattern) => pattern.cells)
      )
    );
    this.atomicUpdateRegions = ([] as AtomicUpdateRegion[]).concat(
      ...patterns.map((pattern) => pattern.atomicUpdateRegions)
    );
    this.rule = new GameOfLife();
  }

  public scroll(viewport: LifeGridBoundingRectangle): LifeState {
    const { inside, outside } = this.cells.partition(viewport);
    if (inside.length > 0) {
      this.cells = new Cells([...this.rule.next(inside), ...outside]);
    }

    return {
      cells: this.cells,
      atomicUpdateRegions: this.atomicUpdateRegions,
    };
  }
}
