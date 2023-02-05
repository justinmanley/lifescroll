import { vec4 } from "../math/linear-algebra/vector4";
import { WebGlInputMatrix } from "../webgl/matrix";
import { WebGlMatrixTransformer } from "../webgl/matrix-transformer";
import { LifeGridBoundingRectangle } from "./coordinates/bounding-rectangle";
import { LifeGridVector2 } from "./coordinates/vector2";
import { LifeGridSize2 } from "./coordinates/size2";
import { fragmentShader } from "./rule";

const MARGIN = 1;
const offset = new LifeGridVector2(MARGIN, MARGIN);

export class GameOfLife {
  private transformer: WebGlMatrixTransformer;

  constructor() {
    this.transformer = new WebGlMatrixTransformer(fragmentShader);
  }

  async next(cells: LifeGridVector2[]): Promise<LifeGridVector2[]> {
    const insideBounds = LifeGridBoundingRectangle.enclosing(cells);
    const insideStart = insideBounds.start();

    const transformed = await this.nextNormalized(
      cells.map((cell) => cell.minus(insideStart)),
      insideBounds.size()
    );
    return transformed.map((cell) => cell.plus(insideStart));
  }

  private async nextNormalized(
    cells: LifeGridVector2[],
    size: LifeGridSize2
  ): Promise<LifeGridVector2[]> {
    const matrix = WebGlInputMatrix.ofSize(size.map((s) => s + 2 * MARGIN));
    cells.forEach((position) => {
      matrix.set(position.plus(offset), vec4(255, 0, 0, 0));
    });

    const positions: LifeGridVector2[] = [];

    const transformed = await this.transformer.transform(matrix);
    transformed.forEach((value, { x, y }) => {
      if (value.x === 255) {
        positions.push(new LifeGridVector2(x, y).minus(offset));
      }
    });

    return positions;
  }
}
