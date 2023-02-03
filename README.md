# Life Scroll

A library for interleaving patterns from Conway's Game of Life with and on top of text on the web.

This library is designed to integrate Life patterns deeply into a text while giving readers full control over their attention. This means making Life patterns instantly accessible, not as static pictures, but fully animated and interactive, ideally with the tempo of the animation controllable by the user. At the same time, the Life patterns should not overwhelm the text or hijack the reader's attention.

In order to integrate Life patterns into text as unobtrusively as possible, this library applies the Life update rule only when the page is scrolled down. This means that readers can control the tempo of updates (by scrolling the page more/faster or less/slower) -- and that when the page is not moving, the pattern doesn't move at all, allowing the reader to focus on the text.

Using the scroll interaction to apply the update rule has the added benefit that there is no need for additional UI (buttons, etc) which might distract from the content.

See "[Life Story](http://justinmanley.work/projects/lifestory/version/1)" for an example using all the features of this library.

## Usage

To interleave patterns from Conway's Game of Life with text, add a <scrolling-game-of-life id="life"> tag to your page and call `document.getElementById("life").initialize()` in a `<script>` tag at the end of the page. You'll need to specify the `grid-scale` on the `scrolling-game-of-life` element, which controls the size of the Life cells relative to the height of a line of text.

A pattern can be laid out on the page by including a `<pattern-anchor>` tag within the `scrolling-game-of-life` element.

Working examples can be found in the `examples/` directory.

## Architecture

### ScrollingGameOfLife

The entrypoint to the library is the `<scrolling-game-of-life>` custom HTML element. Because this element creates a `<canvas>` element and sets it to the size of the viewport, there should be at most one `<scrolling-game-of-life>` element per page.

### PatternAnchor

The `<pattern-anchor>` custom HTML element represents an insertion point for a pattern.

Patterns are specified via the `src` tag, which must point to a file in the [RLE](https://conwaylife.com/wiki/Run_Length_Encoded) ("run-length-encoded") format. This format is widely used in the Life and broader cellular automata ecosystem, so .rle files can be copied and pasted (for example) in the [LifeViewer](https://lazyslug.com/lifeviewer/) for easy visualization and modification.

Every `<pattern-anchor>` must also specify how it should be rendered via a `PatternRenderingOptions` object encoded in JSON according to [this schema](https://github.com/justinmanley/lifescroll/blob/main/src/life/pattern-rendering-options/pattern-rendering-options.ts#L8). This includes specifying how the pattern should be atomically updated, which is described in greater detail [here](https://justinmanley.work/projects/lifestory/technical-challenges).

The `PatternRenderingOptions` object specifies how much space the `<pattern-anchor>` should take up on the page, so the rendering options JSON has been loaded, the width and height of the `<pattern-anchor>` are adjusted to create space for the pattern. Once all patterns have been resized, the `<scrolling-game-of-life>` element collects the cells for each pattern and inserts them into the global, page-wide grid, offset appropriately so that they appear within the space reserved by their `<pattern-anchor>`.

### Life update rule

This library is built on the assumption that the page will be only sparsely populated with "live" cells. That is, most of the page will be "dead" (either filled with text, or empty margins), with patterns appearing only in isolation.

Based on this assumption, this library uses a sparse representation of the Life grid: an array of 2-tuples holding the (x,y) coordinates of the "live" cells.

To apply the Life update rule, the library first partitions the cells which must be updated from those which will remain unchanged. Typically the cells to be updated will only include cells within the viewport along with possibly (depending on how the patterns are configured) cells outside the viewport belonging to a pattern which is partially in the viewport. The library then creates a matrix (i.e. a dense representation) _just_ containing these cells which must be updated. This is usually a _much_ smaller matrix than a dense representation of the entire page would be, since it is (roughly) the size of the viewport.

The library then passes this matrix to WebGL to run the Life update rule in a fragment shader (to be compatible with mobile devices (WebGL ES), this unfortunately means the matrix dimensions must be rounded up to the nearest power of two). Because the Life rule is applied simultaneously across the entire matrix, it is a perfect fit for the GPU's parallel compute model. The Life update rule runs very quickly on the GPU. The GPU writes the result of appling the Life update rule into a new matrix (which it represents as an image). The library then reads this data off the GPU (unfortunately a performance bottleneck) and iterates over the cells in the matrix to find live cells, converting back to a sparse representation. Finally, the library combines the live cells returned from the GPU with those which were not updated by concatenating the two arrays of coordinates.

## Development

Run `webpack --mode development --watch` to compile TypeScript source.

To view the examples, run `npx http-server` and navigate to localhost:8080/examples/example.html.
