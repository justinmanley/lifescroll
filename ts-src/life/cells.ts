import KDBush from "kdbush";
import { LifeGridBoundingRectangle } from "./coordinates/bounding-rectangle";
import { LifeGridPosition } from "./coordinates/position";

export class Cells {
  private cells: KDBush<LifeGridPosition>;

  constructor(cells: LifeGridPosition[]) {
    this.cells = new KDBush(
      cells,
      (cell: LifeGridPosition) => cell.x,
      (cell: LifeGridPosition) => cell.y
    );
  }

  isEmpty(): boolean {
    return this.cells.points.length === 0;
  }

  within(bounds: LifeGridBoundingRectangle): LifeGridPosition[] {
    return this.cells
      .range(bounds.left, bounds.top, bounds.right, bounds.bottom)
      .map((id) => this.cells.points[id]);
  }
}
