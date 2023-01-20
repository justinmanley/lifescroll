import KDBush from "kdbush";
import { LifeGridBoundingRectangle } from "./coordinates/bounding-rectangle";
import { LifeGridPosition } from "./coordinates/position";

interface Partition {
  inside: LifeGridPosition[];
  outside: LifeGridPosition[];
}

export class Cells {
  private cells: KDBush<LifeGridPosition>;
  private ids: Set<number>;

  constructor(cells: LifeGridPosition[]) {
    this.cells = new KDBush(
      cells,
      (cell: LifeGridPosition) => cell.x,
      (cell: LifeGridPosition) => cell.y
    );
    this.ids = new Set(this.cells.ids);
  }

  isEmpty(): boolean {
    return this.cells.points.length === 0;
  }

  within(bounds: LifeGridBoundingRectangle): LifeGridPosition[] {
    return this.cells
      .range(bounds.left, bounds.top, bounds.right, bounds.bottom)
      .map((id) => this.cells.points[id]);
  }

  partition(bounds: LifeGridBoundingRectangle): Partition {
    const inside = this.cells.range(
      bounds.left,
      bounds.top,
      bounds.right,
      bounds.bottom
    );
    return {
      inside: inside.map((id) => this.cells.points[id]),
      outside: [...diff(this.ids, new Set(inside))].map(
        (id) => this.cells.points[id]
      ),
    };
  }
}

const diff = <T>(a: Set<T>, b: Set<T>): Set<T> => {
  const result = new Set<T>();
  a.forEach((value) => {
    if (!b.has(value)) {
      result.add(value);
    }
  });
  return result;
};
