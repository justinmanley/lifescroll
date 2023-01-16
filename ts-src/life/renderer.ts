import { BoundingRectangle } from "../math/geometry/bounding-rectangle";
import { Vector2 } from "../math/linear-algebra/vector2";
import { Cells } from "./cells";
import { LifeGridBoundingRectangle } from "./coordinates/bounding-rectangle";
import { LifeGridPosition } from "./coordinates/position";
import { DebugSettings } from "./debug-settings";
import { LayoutParams } from "./scrolling-game-of-life";

export class LifeRenderer {
  constructor(
    private readonly canvas: HTMLCanvasElement,
    private readonly context: CanvasRenderingContext2D,
    private readonly layoutParams: LayoutParams,
    private readonly debug: DebugSettings
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
      this.debug,
      viewport,
      cells
    ).run();
  }
}

export class Render {
  private cellsRenderer: CellsRenderer;
  private gridRenderer: GridRenderer;

  constructor(
    private readonly canvas: HTMLCanvasElement,
    private readonly context: CanvasRenderingContext2D,
    private readonly layoutParams: LayoutParams,
    private readonly debug: DebugSettings,
    private readonly viewport: BoundingRectangle,
    cells: Cells
  ) {
    const gridViewport = this.getGridViewport(viewport);
    this.cellsRenderer = new CellsRenderer(
      context,
      layoutParams,
      gridViewport,
      cells
    );
    this.gridRenderer = new GridRenderer(context, layoutParams, gridViewport);
  }

  run() {
    this.context.clearRect(0, 0, this.viewport.width, this.viewport.height);
    this.canvas.width = this.viewport.width;
    this.canvas.height = this.viewport.height;
    this.context.setTransform(
      translate(this.viewport.start().map((coord) => coord * -1))
    );
    this.cellsRenderer.render();
    if (this.debug.grid) {
      this.gridRenderer.render();
    }
  }

  private getGridViewport(
    viewport: BoundingRectangle
  ): LifeGridBoundingRectangle {
    const gridViewport = LifeGridBoundingRectangle.fromPage(
      viewport,
      this.layoutParams.cellSizeInPixels
    );

    // Expand the viewport slightly to prevent cells from disappearing just before
    // going offscreen.
    return new LifeGridBoundingRectangle({
      top: gridViewport.top - 1,
      left: gridViewport.left - 1,
      bottom: gridViewport.bottom,
      right: gridViewport.right,
    });
  }
}

class CellsRenderer {
  constructor(
    private readonly context: CanvasRenderingContext2D,
    private readonly layoutParams: LayoutParams,
    private readonly viewport: LifeGridBoundingRectangle,
    private readonly cells: Cells
  ) {}

  public render() {
    this.context.fillStyle = "black";
    this.cells.within(this.viewport).forEach((cell) => this.renderCell(cell));
  }

  private renderCell(cell: LifeGridPosition) {
    const cellSize = this.layoutParams.cellSizeInPixels;
    this.fillSquare(
      cell.map((coord) => coord * cellSize + gridLineHalfWidth),
      cellSize - 2 * gridLineHalfWidth
    );
  }

  private fillSquare(coordinates: Vector2, size: number) {
    this.context.fillRect(coordinates.x, coordinates.y, size, size);
  }
}

class GridRenderer {
  constructor(
    private readonly context: CanvasRenderingContext2D,
    private readonly layoutParams: LayoutParams,
    private readonly viewport: LifeGridBoundingRectangle
  ) {}

  render() {
    this.context.strokeStyle = "grey";
    this.context.lineWidth = gridLineHalfWidth * 2;
    this.renderVerticalLines();
    this.renderHorizontalLines();
  }

  private renderVerticalLines() {
    for (let i = this.viewport.left; i < this.viewport.right; i++) {
      this.renderVerticalLine(i);
    }
  }

  private renderVerticalLine(x: number) {
    this.context.beginPath();

    const start = new LifeGridPosition(x, this.viewport.top)
      .toPage(this.layoutParams.cellSizeInPixels)
      .minus(new Vector2(gridLineHalfWidth, 0));
    this.context.moveTo(start.x, start.y);

    const end = new LifeGridPosition(x, this.viewport.bottom + 1)
      .toPage(this.layoutParams.cellSizeInPixels)
      .minus(new Vector2(gridLineHalfWidth, 0));
    this.context.lineTo(end.x, end.y);

    this.context.stroke();
    this.context.closePath();
  }

  private renderHorizontalLines() {
    for (let i = this.viewport.top; i < this.viewport.bottom; i++) {
      this.renderHorizontalLine(i);
    }
  }

  private renderHorizontalLine(y: number) {
    this.context.beginPath();

    const start = new LifeGridPosition(this.viewport.left, y)
      .toPage(this.layoutParams.cellSizeInPixels)
      .minus(new Vector2(0, gridLineHalfWidth));
    this.context.moveTo(start.x, start.y);

    const end = new LifeGridPosition(this.viewport.right + 1, y)
      .toPage(this.layoutParams.cellSizeInPixels)
      .minus(new Vector2(0, gridLineHalfWidth));
    this.context.lineTo(end.x, end.y);

    this.context.stroke();
    this.context.closePath();
  }
}

//  Constants and helper functions

const gridLineHalfWidth = 1;

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
