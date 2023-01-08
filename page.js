const boundingRectangleWithRespectToDocument = element => {
    // getBoundingClientRect() returns a bounding box relative to
    // the viewport.
    const { top, left, bottom, right } = element.getBoundingClientRect();
    return {
        top: window.scrollY + top,
        left: window.scrollX + left,
        bottom: window.scrollY + bottom,
        right: window.scrollX + right
    }
}

const pageUpdate = patterns => {
    const body = boundingRectangleWithRespectToDocument(document.querySelector('body'));
    const article = boundingRectangleWithRespectToDocument(document.getElementById('article'));

    const params = new Proxy(new URLSearchParams(window.location.search), {
        get: (searchParams, prop) => searchParams.get(prop),
    });

    return {
        PageUpdate: {
            patterns,
            body,
            article,
            cellSizeInPixels: getCellSizeInPixels(),
            debug: params.debug,
        }
    };
}

const scrollPage = () => {
    return {
        ScrollPage: {
            viewport: {
                top: window.scrollY,
                left: window.scrollX,
                bottom: window.scrollY + window.innerHeight,
                right: window.scrollX + window.innerWidth,
            }
        }
    }
}

let fontSizeToCellSize = fontSize => fontSize;

const getCellSizeInPixels = () => {
    const articleElement = document.getElementById('article');

    const testElement = document.createElement('p');
    testElement.innerText = 'Test test';

    articleElement.appendChild(testElement);

    const testElementBounds = testElement.getBoundingClientRect();
    const articleFontSizeInPixels = testElementBounds.bottom - testElementBounds.top;

    articleElement.removeChild(testElement);

    return fontSizeToCellSize(articleFontSizeInPixels);
}

const verticalPadding = 1;

class PatternAnchor extends HTMLElement {
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
        // The bounds must be calculated after the rle file has been fetched
        // and parsed.
        const boundingRectangle = boundingRectangleWithRespectToDocument(this);
        return {
            id: this.id,
            rle,
            bounds: boundingRectangle,
        };
    }

    async loaded() {
        await this.rle;
        return this;
    }

    attributeChangedCallback(name, oldValue, newValue) {
        if (name === 'src') {
            this.rle = fetch(newValue)
                .then(async response => response.text())
                .then(rle => {
                    const cellSizeInPixels = getCellSizeInPixels();
                    const [_, width, height] = [...rle.matchAll(/x = (\d+), y = (\d+)/g)][0];

                    this.style.height = cellSizeInPixels * (parseFloat(height) + 2 * verticalPadding);

                    return rle;
                })
            this.id = newValue;
        }
    }

    static get observedAttributes() { return ['src']; }
}

customElements.define('pattern-anchor', PatternAnchor);


const getPatternAnchors = () =>
    [...document.querySelectorAll('pattern-anchor')];

const onPatternsLoaded = async () => {
    const patternAnchors = await Promise.all(
        getPatternAnchors().map(
            patternAnchor => patternAnchor.loaded()
        )
    );
    return Promise.all(patternAnchors.map(
        patternAnchor => patternAnchor.getPattern()
    ));
};

const initialize = (app, options) => {
    if (options && options.fontSizeToCellSize) {
        fontSizeToCellSize = options.fontSizeToCellSize;
    }

    app.ports.messageReceiver.send(scrollPage());

    onPatternsLoaded().then(patterns => {
        app.ports.messageReceiver.send(pageUpdate(patterns));
    });

    window.addEventListener("scroll", (event) => {
        app.ports.messageReceiver.send(scrollPage());
    });
}