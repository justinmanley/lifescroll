import { vec4 } from "../math/linear-algebra/vector4";
import { RgbaMatrix } from "../webgl/rgba-matrix";
import { RgbaMatrixTransformer } from "../webgl/rgba-matrix-transformer";
import { LifeGridBoundingRectangle } from "./coordinates/bounding-rectangle";
import { LifeGridPosition } from "./coordinates/position";
import { LifeGridSize2 } from "./coordinates/size2";
import { fragmentShader } from "./rule";

const MARGIN = 1;
const offset = new LifeGridPosition(MARGIN, MARGIN);

export class GameOfLife {
  private transformer: RgbaMatrixTransformer;

  constructor() {
    this.transformer = new RgbaMatrixTransformer(fragmentShader);
  }

  next(cells: LifeGridPosition[]): LifeGridPosition[] {
    const insideBounds = LifeGridBoundingRectangle.enclosing(cells);
    const insideStart = insideBounds.start();

    return this.nextNormalized(
      cells.map((cell) => cell.minus(insideStart)),
      insideBounds.size()
    ).map((cell) => cell.plus(insideStart));
  }

  private nextNormalized(
    cells: LifeGridPosition[],
    size: LifeGridSize2
  ): LifeGridPosition[] {
    const matrix = RgbaMatrix.ofSize(size.map((s) => s + 2 * MARGIN));
    cells.forEach((position) => {
      matrix.set(position.plus(offset), vec4(255, 0, 0, 0));
    });

    const positions: LifeGridPosition[] = [];

    this.transformer.transform(matrix).forEach((value, { x, y }) => {
      if (value.x === 255) {
        positions.push(new LifeGridPosition(x, y).minus(offset));
      }
    });

    return positions;
  }
}
