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
import { vec2 } from "../math/linear-algebra/vector2";
import { partition } from "lodash";
import { Role } from "../life/pattern-rendering-options/role";

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

  private interactionPrompts: LifeGridVector2[] = [];

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
      this.onClick(event);
    });

    this.canvas = document.createElement("canvas");
    // Must be set up-front to take the canvas out of the flow and prevent
    // the page layout params from containing an additional unnecessary offset.
    this.canvas.style.position = "fixed";
  }

  private onScroll() {
    this.cellSizeInPixels.then((cellSizeInPixels) => {
      const viewport = this.viewport();
      const state = this.life?.scroll(
        LifeGridBoundingRectangle.fromPage(this.viewport(), cellSizeInPixels)
      );
      if (state) {
        this.renderer?.render(viewport, state);
      }
    });
  }

  private onClick(event: MouseEvent) {
    this.cellSizeInPixels.then((cellSizeInPixels) => {
      const state = this.life?.toggleCell(
        LifeGridVector2.fromPage(
          vec2(window.scrollX + event.clientX, window.scrollY + event.clientY),
          cellSizeInPixels
        )
      );
      this.interactionPrompts = [];
      if (state) {
        this.renderer?.render(this.viewport(), state);
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

    const [patterns, interactionPrompts] = partition(
      allPatterns,
      (pattern) => pattern.role === Role.Pattern
    );
    this.interactionPrompts = interactionPrompts.flatMap(
      (pattern) => pattern.cells
    );

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
      layoutParams,
      color,
      this.debug
    );

    this.renderer.render(viewport, this.life.state);
    this.renderer.startAnimation(
      () => this.viewport(),
      () => this.interactionPrompts
    );
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
    center,
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
          preferredHorizontalRange: center.horizontal(),
          anchorStart:
            boundingRectangleWithRespectToDocument(patternAnchor).start(),
        });
      })
    );
  }

  private layoutParams(cellSizeInPixels: number): LayoutParams {
    const centerElement = this.querySelector(`[${CENTER_ATTRIBUTE}]`);
    if (!centerElement) {
      console.warn(
        `Could not find center element with attribute ${CENTER_ATTRIBUTE}`
      );
    }

    return {
      full: boundingRectangleWithRespectToDocument(this),
      center: centerElement
        ? boundingRectangleWithRespectToDocument(centerElement)
        : BoundingRectangle.empty(),
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

const CENTER_ATTRIBUTE = "scrolling-game-of-life-center";

customElements.define("scrolling-game-of-life", ScrollingGameOfLifeElement);
