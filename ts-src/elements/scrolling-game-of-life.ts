import { BoundingRectangle } from "../bounding-rectangle";
import { LayoutParams, ScrollingGameOfLife } from "../life/scrolling-game-of-life";
import { isPatternAnchor, PatternAnchorElement } from "./pattern-anchor";

class ScrollingGameOfLifeElement extends HTMLElement {
    private gridScale = 1;

    private life?: ScrollingGameOfLife;

    constructor() {
        super();

        window.addEventListener("scroll", (event) => {
            this.onScroll();
        });
    }

    attributeChangedCallback(name: string, _: unknown, newValue: unknown) {
        if (name === 'grid-scale' && typeof newValue === 'number') {
            this.gridScale = newValue;
        }
    }

    static get observedAttributes() { return ['grid-scale']; }

    async render(): Promise<void> {
        const cellSizeInPixels = this.getCellSizeInPixels();
        const patterns = await this.patterns(cellSizeInPixels);
        const layoutParams = this.layoutParams(cellSizeInPixels);
        this.life = new ScrollingGameOfLife(patterns, layoutParams);
    }

    private getCellSizeInPixels() {
        const testElement = document.createElement('p');
        testElement.innerText = 'Test test';

        this.appendChild(testElement);

        const testElementBounds = testElement.getBoundingClientRect();
        const articleFontSizeInPixels = testElementBounds.bottom - testElementBounds.top;

        this.removeChild(testElement);

        return articleFontSizeInPixels / this.gridScale;
    }

    private patternAnchors(): PatternAnchorElement[] {
        return [...this.querySelectorAll('pattern-anchor')].filter(isPatternAnchor);
    }

    private async patterns(cellSizeInPixels: number) {
        const patternAnchors = this.patternAnchors();
        await Promise.all(patternAnchors.map(
            patternAnchor => patternAnchor.updateSize({ cellSizeInPixels })
        ));
        // The document-relative bounds must be calculated only after all 
        // PatternAnchor elements have updated their size.
        return await Promise.all(patternAnchors.map(
            async patternAnchor => {
                const pattern = await patternAnchor.getPattern();
                return {
                    ...pattern,
                    bounds: boundingRectangleWithRespectToDocument(patternAnchor)
                };
            }
        ));
    }

    private layoutParams(cellSizeInPixels: number): LayoutParams {
        const centerElement = this.querySelector(`[${CENTER_ATTRIBUTE}]`);
        if (!centerElement) {
            console.warn(`Could not find center element with attribute ${CENTER_ATTRIBUTE}`);
        }

        return {
            full: boundingRectangleWithRespectToDocument(this),
            center: centerElement ? boundingRectangleWithRespectToDocument(centerElement) : BoundingRectangle.empty(),
            cellSizeInPixels
        }
    }

    private onScroll() {
        this.life?.onScroll(
            new BoundingRectangle({
                top: window.scrollY,
                left: window.scrollX,
                bottom: window.scrollY + window.innerHeight,
                right: window.scrollX + window.innerWidth,
            })
        );
    }
}

const boundingRectangleWithRespectToDocument = (element: Element): BoundingRectangle => {
    // getBoundingClientRect() returns a bounding box relative to
    // the viewport.
    const { top, left, bottom, right } = element.getBoundingClientRect();
    return new BoundingRectangle({
        top: window.scrollY + top,
        left: window.scrollX + left,
        bottom: window.scrollY + bottom,
        right: window.scrollX + right
    });
}

const CENTER_ATTRIBUTE = 'scrolling-game-of-life-center';

customElements.define('scrolling-game-of-life', ScrollingGameOfLifeElement);

