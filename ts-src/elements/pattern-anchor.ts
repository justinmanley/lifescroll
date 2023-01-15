import { Cells } from "../life/cells";
import { LifeGridPosition } from "../life/coordinates/position";
import { Pattern } from "../life/pattern";
import { PatternRenderingOptions } from "../life/pattern-rendering-options/pattern-rendering-options";
import { parse } from "../life/rle-parser";

export class PatternAnchorElement extends HTMLElement {
  private cells: Promise<LifeGridPosition[]>;
  private renderingOptions: Promise<PatternRenderingOptions>;
  private patternId: Promise<string>;

  private resolveCells: (
    value: LifeGridPosition[] | PromiseLike<LifeGridPosition[]>
  ) => void = () => {};
  private resolveRenderingOptions: (
    value: PatternRenderingOptions | PromiseLike<PatternRenderingOptions>
  ) => void = () => {};
  private resolvePatternId: (value: string | PromiseLike<string>) => void =
    () => {};

  constructor() {
    super();
    this.cells = new Promise((resolve) => {
      this.resolveCells = resolve;
    });
    this.renderingOptions = new Promise((resolve) => {
      this.resolveRenderingOptions = resolve;
    });
    this.patternId = new Promise((resolve) => {
      this.resolvePatternId = resolve;
    });
  }

  /*
   * It is important that this is not called until all pattern anchors have their
   * size set. If this is called before all pattern anchors have their size set,
   * the pattern anchor may shift position after getPattern() has calculated the
   * bounding rectangle and sent it to Elm. This will result in the pattern being
   * rendered in the wrong place on the page.
   *
   * This race condition can be seen by adding a delay to the RLE response:
   *   const delay = (ms) => {
   *     return new Promise(resolve => setTimeout(resolve, ms));
   *   }
   *
   * And:
   *   this.rle = fetch(newValue)
   *     .then(async response => {
   *       await delay(Math.random() * 2000);
   *      return response.text()
   *     })
   *
   * Keeping this dynamic rather than requiring developers to statically specify the
   * height and width of each PatternAnchor maintains flexibility for different layout
   * options in the future (for example, laying out patterns in the margin on desktop
   * which would mean the pattern anchors wouldn't take up any vertical space).
   */
  async getPattern(): Promise<Pattern> {
    const cells = await this.cells;
    const renderingOptions = await this.renderingOptions;
    const id = await this.patternId;
    return { id, cells, renderingOptions };
  }

  attributeChangedCallback(name: string, _: unknown, newValue: unknown) {
    if (name === "src" && typeof newValue === "string") {
      fetch(newValue).then(async (response) => {
        const rleString = await response.text();
        this.resolveCells(
          parse(rleString).map(([x, y]) => new LifeGridPosition(x, y))
        );
      });
      this.resolvePatternId(newValue);
    }

    if (name === "rendering-options" && typeof newValue === "string") {
      fetch(newValue).then(async (response) => {
        const renderingOptionsJson = await response.json();
        this.resolveRenderingOptions(
          PatternRenderingOptions.decode(renderingOptionsJson)
        );
      });
    }
  }

  static get observedAttributes() {
    return ["src", "rendering-options"];
  }

  async updateSize({
    cellSizeInPixels,
  }: {
    cellSizeInPixels: number;
  }): Promise<void> {
    const renderingOptions = await this.renderingOptions;
    this.style.height = `${
      cellSizeInPixels * (renderingOptions.reserve.height + 2 * verticalPadding)
    }`;
  }
}

export const isPatternAnchor = (object: any): object is PatternAnchorElement =>
  object instanceof PatternAnchorElement;

const verticalPadding = 1;

customElements.define("pattern-anchor", PatternAnchorElement);
