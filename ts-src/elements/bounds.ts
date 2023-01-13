
const boundingRectangleWithRespectToDocument = (element: HTMLElement) => {
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
