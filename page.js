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

    attributeChangedCallback(name, oldValue, newValue) {
        if (name === 'src') {
            this.rle = fetch(newValue)
                .then(response => response.text())
                .then(rle => {
                    const cellSizeInPixels = getCellSizeInPixels();
                    const [_, width, height] = [...rle.matchAll(/x = (\d+), y = (\d+)/g)][0];

                    this.style.display = 'block';
                    this.style.height = cellSizeInPixels * (parseFloat(height) + 2 * verticalPadding);

                    return rle;
                })
            this.id = newValue;
        }
    }

    static get observedAttributes() { return ['src']; }
}

customElements.define('pattern-anchor', PatternAnchor);



const getPatterns = () =>
    Promise.all(
        [...document.querySelectorAll('pattern-anchor')].map(
            patternAnchor => patternAnchor.getPattern()
        )
    )

const initialize = (app, options) => {
    if (options && options.fontSizeToCellSize) {
        fontSizeToCellSize = options.fontSizeToCellSize;
    }

    app.ports.messageReceiver.send(scrollPage());
    getPatterns().then(patterns => {
        app.ports.messageReceiver.send(pageUpdate(patterns));
    });

    window.addEventListener("scroll", (event) => {
        app.ports.messageReceiver.send(scrollPage());
    });
}