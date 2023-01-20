import { BoundingRectangle } from "../math/geometry/bounding-rectangle";
import { Cells } from "./cells";
import { LifeGridBoundingRectangle } from "./coordinates/bounding-rectangle";
import { LifeGridPosition } from "./coordinates/position";
import { LifeGridSize2 } from "./coordinates/size2";
import { LaidOutPattern } from "./pattern";
import { RgbaMatrixTransformer } from "../webgl/rgba-matrix-transformer";
import { RgbaMatrix } from "../webgl/rgba-matrix";
import { vec4 } from "../math/linear-algebra/vector4";

export interface LayoutParams {
  full: BoundingRectangle;
  center: BoundingRectangle;
  cellSizeInPixels: number;
}

export class ScrollingGameOfLife {
  private transformer: RgbaMatrixTransformer;

  private cells: Cells;

  constructor(patterns: LaidOutPattern[], fragmentShaderSource: string) {
    this.cells = new Cells(
      ([] as LifeGridPosition[]).concat(
        ...patterns.map((pattern) => pattern.cells)
      )
    );

    this.transformer = new RgbaMatrixTransformer(fragmentShaderSource);
  }

  public scroll(viewport: LifeGridBoundingRectangle): Cells {
    const { inside, outside } = this.cells.partition(viewport);
    if (inside.length === 0) {
      return this.cells;
    }

    const positions = [...this.next(inside), ...outside];

    this.cells = new Cells(positions);

    return this.cells;
  }

  private next(alive: LifeGridPosition[]): LifeGridPosition[] {
    const insideBounds = LifeGridBoundingRectangle.enclosing(alive);
    const insideStart = insideBounds.start().minus(new LifeGridPosition(1, 1));

    return this.nextNormalized(
      alive.map((cell) => cell.minus(insideStart)),
      insideBounds.size().map((s) => s + 2)
    ).map((cell) => cell.plus(insideStart));
  }

  private nextNormalized(
    cells: LifeGridPosition[],
    size: LifeGridSize2
  ): LifeGridPosition[] {
    const matrix = RgbaMatrix.ofSize(size);
    cells.forEach((position) => {
      matrix.set(position, vec4(255, 0, 0, 0));
    });

    const positions: LifeGridPosition[] = [];

    this.transformer.transform(matrix).forEach((value, { x, y }) => {
      if (value.x === 255) {
        positions.push(new LifeGridPosition(x, y));
      }
    });

    return positions;
  }
}
