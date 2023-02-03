import { BoundingRectangle } from "../math/geometry/bounding-rectangle";
import {
  LayoutParams,
  ScrollingGameOfLife,
} from "../life/scrolling-game-of-life";
import { isPatternAnchor, PatternAnchorElement } from "./pattern-anchor";
import { LifeRenderer } from "../life/renderer";
import { DebugSettings } from "../life/debug-settings";
import { LifeGridBoundingRectangle } from "../life/coordinates/bounding-rectangle";
import { LaidOutPattern } from "../life/pattern";
import { LifeGridVector2 } from "../life/coordinates/vector2";
import { vec2, Vector2 } from "../math/linear-algebra/vector2";
import { partition } from "lodash";
import { Role } from "../life/pattern-rendering-options/role";
import { Interval } from "../math/geometry/interval";

class ScrollingGameOfLifeElement extends HTMLElement {
  private gridScale: Promise<number>;
  private cellSizeInPixels: Promise<number>;

  private resolveGridScale: (value: number | PromiseLike<number>) => void =
    () => {};
  private resolveCellSizeInPixels: (
    value: number | PromiseLike<number>
  ) => void = () => {};

  private canvas: HTMLCanvasElement;

  private life?: ScrollingGameOfLife;
  private renderer?: LifeRenderer;
  private verticalBounds?: Interval;

  private readonly debug = new DebugSettings();

  constructor() {
    super();

    this.gridScale = new Promise((resolve) => {
      this.resolveGridScale = resolve;
    });
    this.cellSizeInPixels = new Promise((resolve) => {
      this.resolveCellSizeInPixels = resolve;
    });

    window.addEventListener("scroll", (event) => {
      this.onScroll();
    });

    window.addEventListener("click", (event) => {
      const position = vec2(
        window.scrollX + event.clientX,
        window.scrollY + event.clientY
      );
      if (this.verticalBounds?.contains(position.y)) {
        this.onClick(position);
      }
    });

    this.canvas = document.createElement("canvas");
    // Must be set up-front to take the canvas out of the flow and prevent
    // the page layout params from containing an additional unnecessary offset.
    this.canvas.style.position = "fixed";
  }

  private onScroll() {
    this.cellSizeInPixels.then((cellSizeInPixels) => {
      const state = this.life?.scroll(
        LifeGridBoundingRectangle.fromPage(this.viewport(), cellSizeInPixels)
      );
      if (this.renderer) {
        this.renderer.viewport = this.viewport();
        if (state) {
          this.renderer.lifeState = state;
        }
      }
    });
  }

  private onClick(position: Vector2) {
    this.cellSizeInPixels.then((cellSizeInPixels) => {
      const state = this.life?.toggleCell(
        LifeGridVector2.fromPage(position, cellSizeInPixels)
      );
      if (this.renderer && state) {
        this.renderer.interactionPrompts = [];
      }
    });
  }

  private viewport(): BoundingRectangle {
    return new BoundingRectangle({
      top: window.scrollY,
      left: window.scrollX,
      bottom: window.scrollY + window.innerHeight,
      right: window.scrollX + window.innerWidth,
    });
  }

  // --------------
  // Lifecycle
  // --------------

  attributeChangedCallback(name: string, _: unknown, newValue: unknown) {
    if (name === "grid-scale" && typeof newValue === "string") {
      this.resolveGridScale(parseInt(newValue, 10));
    }
  }

  static get observedAttributes() {
    return ["grid-scale"];
  }

  connectedCallback() {
    this.appendChild(this.canvas);
  }

  disconnectedCallback() {
    this.removeChild(this.canvas);
  }

  // --------------
  // Initialization
  // --------------

  async initialize(): Promise<void> {
    const cellSizeInPixels = await this.getCellSizeInPixels();
    this.resolveCellSizeInPixels(cellSizeInPixels);

    const layoutParams = this.layoutParams(cellSizeInPixels);
    const allPatterns = await this.patterns(layoutParams);
    const viewport = this.viewport();

    const bounds = boundingRectangleWithRespectToDocument(this);

    const [patterns, interactionPrompts] = partition(
      allPatterns,
      (pattern) => pattern.role === Role.Pattern
    );

    this.verticalBounds = bounds.vertical();

    this.life = new ScrollingGameOfLife(
      patterns,
      LifeGridBoundingRectangle.fromPage(viewport, cellSizeInPixels)
    );

    const context = this.canvas.getContext("2d");
    if (!context) {
      console.warn("Missing canvas rendering context");
      return;
    }

    const color = window.getComputedStyle(this).getPropertyValue("color");

    this.renderer = new LifeRenderer(
      this.canvas,
      context,
      this,
      layoutParams,
      color,
      this.debug
    );

    this.renderer.viewport = viewport;
    this.renderer.interactionPrompts = interactionPrompts.flatMap(
      (pattern) => pattern.cells
    );
    this.renderer.lifeState = this.life.state;

    this.renderer.start();
  }

  private async getCellSizeInPixels(): Promise<number> {
    const testElement = document.createElement("p");
    testElement.innerText = "Test test";

    this.appendChild(testElement);

    const testElementBounds = testElement.getBoundingClientRect();
    const articleFontSizeInPixels =
      testElementBounds.bottom - testElementBounds.top;

    this.removeChild(testElement);

    const gridScale = await this.gridScale;

    return articleFontSizeInPixels / gridScale;
  }

  private patternAnchors(): PatternAnchorElement[] {
    return [...this.querySelectorAll("pattern-anchor")].filter(isPatternAnchor);
  }

  private async patterns({
    cellSizeInPixels,
    full,
  }: LayoutParams): Promise<LaidOutPattern[]> {
    const patternAnchors = this.patternAnchors();
    await Promise.all(
      patternAnchors.map((patternAnchor) =>
        patternAnchor.updateSize({ cellSizeInPixels })
      )
    );

    // The document-relative bounds must be calculated only after all
    // PatternAnchor elements have updated their size (above).
    return await Promise.all(
      patternAnchors.map(async (patternAnchor) => {
        const pattern = await patternAnchor.getPattern();

        return pattern.layout({
          cellSizeInPixels,
          preferredHorizontalRange: full.horizontal(),
          anchorStart:
            boundingRectangleWithRespectToDocument(patternAnchor).start(),
        });
      })
    );
  }

  private layoutParams(cellSizeInPixels: number): LayoutParams {
    return {
      full: boundingRectangleWithRespectToDocument(this),
      cellSizeInPixels,
    };
  }
}

const boundingRectangleWithRespectToDocument = (
  element: Element
): BoundingRectangle => {
  // getBoundingClientRect() returns a bounding box relative to
  // the viewport.
  const { top, left, bottom, right } = element.getBoundingClientRect();
  return new BoundingRectangle({
    top: window.scrollY + top,
    left: window.scrollX + left,
    bottom: window.scrollY + bottom,
    right: window.scrollX + right,
  });
};

customElements.define("scrolling-game-of-life", ScrollingGameOfLifeElement);