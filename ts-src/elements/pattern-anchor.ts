export class PatternAnchorElement extends HTMLElement {
    private rle: Promise<string>;
    private renderingOptions: Promise<string>;
    private patternId: Promise<string>;

    private resolveRle: (value: string | PromiseLike<string>) => void = () => { };
    private resolveRenderingOptions: (value: string | PromiseLike<string>) => void = () => { };
    private resolvePatternId: (value: string | PromiseLike<string>) => void = () => { };

    constructor() {
        super();
        this.rle = new Promise(resolve => {
            this.resolveRle = resolve;
        });
        this.renderingOptions = new Promise(resolve => {
            this.resolveRenderingOptions = resolve;
        });
        this.patternId = new Promise(resolve => {
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
    async getPattern() {
        const rle = await this.rle;
        const renderingOptions = await this.renderingOptions;
        const patternId = await this.patternId;
        return {
            id: patternId,
            patternRle: rle,
            patternRenderingOptionsJson: renderingOptions,
        };
    }

    async loaded() {
        await Promise.all([this.rle, this.renderingOptions]);
        return this;
    }

    attributeChangedCallback(name: string, _: unknown, newValue: unknown) {
        if (name === 'src' && typeof newValue === 'string') {
            fetch(newValue)
                .then(response => {
                    this.resolveRle(response.text())
                });
            this.resolvePatternId(newValue);
        }

        if (name === 'rendering-options' && typeof newValue === 'string') {
            fetch(newValue)
                .then(response => {
                    this.resolveRenderingOptions(response.text());

                });
        }
    }

    static get observedAttributes() { return ['src', 'rendering-options']; }

    async updateSize({ cellSizeInPixels }: { cellSizeInPixels: number }): Promise<void> {
        const rle = await this.rle;
        const [_, width, height] = [...rle.matchAll(/x = (\d+), y = (\d+)/g)][0];
        this.style.height = `${cellSizeInPixels * (parseFloat(height) + 2 * verticalPadding)}`;
    }
}

export const isPatternAnchor = (object: any): object is PatternAnchorElement =>
    object instanceof PatternAnchorElement;

const verticalPadding = 1;



customElements.define('pattern-anchor', PatternAnchorElement);