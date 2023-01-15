import KDBush from "kdbush";
import { Vector2 } from "../math/linear-algebra/vector2";

export class Cells {
  private cells: KDBush<Vector2>;

  constructor(cells: [number, number][]) {
    this.cells = new KDBush(cells);
  }

  isEmpty(): boolean {
    return this.cells.points.length === 0;
  }
}
