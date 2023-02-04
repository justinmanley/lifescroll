import { BoundingRectangle } from "../math/geometry/bounding-rectangle";
import { vec2, Vector2 } from "../math/linear-algebra/vector2";
import { LifeGridBoundingRectangle } from "./coordinates/bounding-rectangle";
import { LifeGridVector2 } from "./coordinates/vector2";
import { DebugSettings } from "./debug-settings";
import { LayoutParams, LifeState } from "./scrolling-game-of-life";
import Color from "colorjs.io";

interface RendererLifeState extends LifeState {
  deceased: LifeGridVector2[];
}

export class LifeRenderer {
  private interactionPromptRenderer: ColorAnimatingCellsRenderer;

  private isRenderRequired = false;

  private _viewport = BoundingRectangle.empty();
  private _gridViewport = LifeGridBoundingRectangle.empty();
  private _lifeState: RendererLifeState = {
    cells: [],
    deceased: [],
    atomicUpdates: [],
  };
  private _interactionPrompts: LifeGridVector2[] = [];

  private timeElapsed = 0;
  private viewportLastUpdatedTime = 0;

  private initialElementTop = 0;
  private previousElementTopOffset = 0;

  private readonly cellRenderingOptions: CellRenderingOptions;

  constructor(
    private readonly canvas: HTMLCanvasElement,
    private readonly context: CanvasRenderingContext2D,
    private readonly element: HTMLElement,
    private readonly layoutParams: LayoutParams,
    private readonly cellColor: string,
    private readonly debug: DebugSettings
  ) {
    this.canvas.style.position = "fixed";
    this.canvas.style.height = "100%";
    this.canvas.style.width = "100%";
    this.canvas.style.top = "0";
    this.canvas.style.left = "0";

    this.cellRenderingOptions = {
      color: cellColor,
      margin: gridLineHalfWidth,
    };

    const startColor = new Color(cellColor);
    const endColor = new Color("white");
    this.interactionPromptRenderer = new ColorAnimatingCellsRenderer(
      context,
      layoutParams,
      { start: startColor, end: endColor },
      4
    );

    this.initialElementTop = this.elementTop();
  }

  public start() {
    requestAnimationFrame((timeInMs) => this.render(timeInMs));
  }

  private render(timeInMs: number) {
    const offset = this.elementTopOffset();
    this.isRenderRequired =
      this.isRenderRequired || offset !== this.previousElementTopOffset;

    if (this.isRenderRequired) {
      new Render(
        this.canvas,
        this.context,
        this.layoutParams,
        this.cellRenderingOptions,
        this.debug,
        offset,
        this._viewport,
        this._gridViewport,
        this._lifeState
      ).run();
    }

    const viewportIsStationary = timeInMs - this.viewportLastUpdatedTime > 100;
    if (this.isRenderRequired || viewportIsStationary) {
      // For performance reasons (to prevent the cells from looking like they
      // are sliding around on top of the text), we only want to run this if a
      // render is actually required. Running it more frequently than necessary
      // slows down rendering. However, scrolling is normally the only thing
      // that would require a render, and we want the interaction prompt
      // animation to render even when the page is stationary. In that case, we
      // don't need to worry as much about performance.
      this.interactionPromptRenderer.render(
        this._gridViewport,
        this._interactionPrompts,
        timeInMs
      );
    }

    this.isRenderRequired = false;

    this.timeElapsed = timeInMs;

    requestAnimationFrame((t) => this.render(t));
  }

  private elementTopOffset(): number {
    return this.elementTop() - this.initialElementTop;
  }

  private elementTop(): number {
    return this.element.getBoundingClientRect().top + window.scrollY;
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

  set viewport(bounds: BoundingRectangle) {
    this._viewport = bounds;
    this._gridViewport = this.getGridViewport(bounds);
    this.viewportLastUpdatedTime = this.timeElapsed;
    this.isRenderRequired = true;
  }

  set lifeState(lifeState: RendererLifeState) {
    this._lifeState = lifeState;
    this.isRenderRequired = true;
  }

  set interactionPrompts(positions: LifeGridVector2[]) {
    this._interactionPrompts = positions;
    this.isRenderRequired = true;
  }
}

export class Render {
  private liveCellsRenderer: CellsRenderer;
  private deceasedCellsRenderer: CellsRenderer;
  private gridRenderer: GridRenderer;
  private atomicUpdateBoundsRenderer: BoundsRenderer;

  constructor(
    private readonly canvas: HTMLCanvasElement,
    private readonly context: CanvasRenderingContext2D,
    layoutParams: LayoutParams,
    cellRenderingOptions: CellRenderingOptions,
    private readonly debug: DebugSettings,
    private readonly yOffset: number,
    private readonly viewport: BoundingRectangle,
    gridViewport: LifeGridBoundingRectangle,
    state: RendererLifeState
  ) {
    this.liveCellsRenderer = new CellsRenderer(
      context,
      layoutParams,
      gridViewport,
      state.cells,
      cellRenderingOptions
    );
    this.deceasedCellsRenderer = new CellsRenderer(
      context,
      layoutParams,
      gridViewport,
      state.deceased,
      { color: "white", margin: -1 }
    );

    this.gridRenderer = new GridRenderer(context, layoutParams, gridViewport);
    this.atomicUpdateBoundsRenderer = new BoundsRenderer(
      context,
      layoutParams,
      gridViewport,
      state.atomicUpdates.flatMap((atomicUpdate) => {
        return this.debug.atomicUpdates || atomicUpdate.visualize
          ? atomicUpdate.bounds
          : [];
      })
    );
  }

  run() {
    this.context.clearRect(0, 0, this.viewport.width, this.viewport.height);
    this.canvas.width = this.viewport.width;
    this.canvas.height = this.viewport.height;
    this.context.setTransform(
      translate(
        this.viewport
          .start()
          .map((coord) => coord * -1)
          .plus(vec2(0, this.yOffset))
      )
    );
    this.deceasedCellsRenderer.render();
    this.liveCellsRenderer.render();
    if (this.debug.grid) {
      this.gridRenderer.render();
    }
    this.atomicUpdateBoundsRenderer.render();
  }
}

interface CellRenderingOptions {
  color: string;
  margin: number;
}

class CellsRenderer {
  constructor(
    private readonly context: CanvasRenderingContext2D,
    private readonly layoutParams: LayoutParams,
    private readonly viewport: LifeGridBoundingRectangle,
    private readonly cells: LifeGridVector2[],
    private readonly options: CellRenderingOptions
  ) {}

  public render() {
    this.context.fillStyle = this.options.color ?? "black";
    this.cells
      .filter((cell) => this.viewport.contains(cell))
      .forEach((cell) => this.renderCell(cell));
  }

  protected renderCell(cell: LifeGridVector2) {
    const cellSize = this.layoutParams.cellSizeInPixels;
    this.fillSquare(
      cell.map((coord) => coord * cellSize + this.options.margin),
      cellSize - 2 * this.options.margin
    );
  }

  protected fillSquare(coordinates: Vector2, size: number) {
    this.context.fillRect(coordinates.x, coordinates.y, size, size);
  }
}

class ColorAnimatingCellsRenderer {
  private colorSteps: string[];

  constructor(
    private readonly context: CanvasRenderingContext2D,
    private readonly layoutParams: LayoutParams,
    { start, end }: { start: Color; end: Color },
    private frequencyInMs: number
  ) {
    const steps = Color.steps(start, end, {
      outputSpace: "srgb",
      steps: 256,
    }).map((color) =>
      color.toString({
        format: "hex",
      })
    );
    this.colorSteps = steps.concat([...steps].reverse());
  }

  public render(
    viewport: LifeGridBoundingRectangle,
    cells: LifeGridVector2[],
    timeInMs: number
  ) {
    const color =
      this.colorSteps[
        Math.floor((timeInMs / this.frequencyInMs) % this.colorSteps.length)
      ];
    new CellsRenderer(this.context, this.layoutParams, viewport, cells, {
      color,
      margin: gridLineHalfWidth,
    }).render();
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
    for (let i = this.viewport.left; i <= this.viewport.right; i++) {
      this.renderVerticalLine(i);
    }
  }

  private renderVerticalLine(x: number) {
    this.context.beginPath();

    const start = new LifeGridVector2(x, this.viewport.top)
      .toPage(this.layoutParams.cellSizeInPixels)
      .minus(new Vector2(gridLineHalfWidth, 0));
    this.context.moveTo(start.x, start.y);

    const end = new LifeGridVector2(x, this.viewport.bottom + 1)
      .toPage(this.layoutParams.cellSizeInPixels)
      .minus(new Vector2(gridLineHalfWidth, 0));
    this.context.lineTo(end.x, end.y);

    this.context.stroke();
    this.context.closePath();
  }

  private renderHorizontalLines() {
    for (let i = this.viewport.top; i <= this.viewport.bottom; i++) {
      this.renderHorizontalLine(i);
    }
  }

  private renderHorizontalLine(y: number) {
    this.context.beginPath();

    const start = new LifeGridVector2(this.viewport.left, y)
      .toPage(this.layoutParams.cellSizeInPixels)
      .minus(new Vector2(0, gridLineHalfWidth));
    this.context.moveTo(start.x, start.y);

    const end = new LifeGridVector2(this.viewport.right + 1, y)
      .toPage(this.layoutParams.cellSizeInPixels)
      .minus(new Vector2(0, gridLineHalfWidth));
    this.context.lineTo(end.x, end.y);

    this.context.stroke();
    this.context.closePath();
  }
}

class BoundsRenderer {
  constructor(
    private readonly context: CanvasRenderingContext2D,
    private readonly layoutParams: LayoutParams,
    private readonly viewport: LifeGridBoundingRectangle,
    private readonly boundsList: LifeGridBoundingRectangle[]
  ) {}

  render() {
    this.context.strokeStyle = "red";
    this.context.lineWidth = gridLineHalfWidth * 2;

    for (const bounds of this.boundsList) {
      this.renderBounds(bounds);
    }
  }

  private renderBounds(bounds: LifeGridBoundingRectangle) {
    const pageBounds = bounds.toPage(this.layoutParams.cellSizeInPixels);

    this.context.strokeRect(
      pageBounds.left - gridLineHalfWidth,
      pageBounds.top - gridLineHalfWidth,
      pageBounds.width + gridLineHalfWidth,
      pageBounds.height + gridLineHalfWidth
    );
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
