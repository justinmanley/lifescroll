import { BoundingRectangle } from "../math/geometry/bounding-rectangle";
import { Vector2 } from "../math/linear-algebra/vector2";
import { Cells } from "./cells";
import { LifeGridBoundingRectangle } from "./coordinates/bounding-rectangle";
import { LayoutParams } from "./scrolling-game-of-life";

export class LifeRenderer {
  constructor(
    private readonly canvas: HTMLCanvasElement,
    private readonly context: CanvasRenderingContext2D,
    private readonly layoutParams: LayoutParams
  ) {
    this.canvas.style.position = "fixed";
    this.canvas.style.height = "100%";
    this.canvas.style.width = "100%";
    this.canvas.style.top = "0";
    this.canvas.style.left = "0";
  }

  public render(viewport: BoundingRectangle, cells: Cells) {
    new Render(
      this.canvas,
      this.context,
      this.layoutParams,
      viewport,
      cells
    ).run();
  }
}

export class Render {
  private gridViewport: LifeGridBoundingRectangle;

  constructor(
    private readonly canvas: HTMLCanvasElement,
    private readonly context: CanvasRenderingContext2D,
    private readonly layoutParams: LayoutParams,
    private readonly viewport: BoundingRectangle,
    private readonly cells: Cells
  ) {
    const gridViewport = LifeGridBoundingRectangle.fromPage(
      viewport,
      this.layoutParams.cellSizeInPixels
    );

    // Expand the viewport slightly to prevent cells from disappearing just before
    // going offscreen.
    this.gridViewport = new LifeGridBoundingRectangle({
      top: gridViewport.top - 1,
      left: gridViewport.left - 1,
      bottom: gridViewport.bottom,
      right: gridViewport.right,
    });
  }

  run() {
    this.context.clearRect(0, 0, this.viewport.width, this.viewport.height);
    this.canvas.width = this.viewport.width;
    this.canvas.height = this.viewport.height;
    this.context.setTransform(
      translate(this.viewport.start().map((coord) => coord * -1))
    );
    this.renderCells();
  }

  private renderCells() {
    this.cells
      .within(this.gridViewport)
      .forEach((cell) => this.renderCell(cell));
  }

  private renderCell(cell: Vector2) {
    const cellSize = this.layoutParams.cellSizeInPixels;
    this.context.fillStyle = "black";
    this.fillSquare(
      cell.map((coord) => coord * cellSize + gridLineHalfWidth),
      cellSize - 2 * gridLineHalfWidth
    );
  }

  private fillSquare(coordinates: Vector2, size: number) {
    this.context.fillRect(coordinates.x, coordinates.y, size, size);
  }
}

const gridLineHalfWidth = 2;

const translate = (translation: Vector2): DOMMatrix2DInit => {
  return {
    a: 1,
    b: 0,
    c: 0,
    d: 1,
    e: translation.x,
    f: translation.y,
  };
};
