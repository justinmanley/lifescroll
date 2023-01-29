import { property, assert, integer, uint8Array } from "fast-check";
import { vec2 } from "../../src/math/linear-algebra/vector2";
import { vec4 } from "../../src/math/linear-algebra/vector4";
import {
  NUM_CHANNELS,
  WebGlInputMatrix,
  WebGlOutputMatrix,
} from "../../src/webgl/matrix";
import { WebGlMatrixTransformer } from "../../src/webgl/matrix-transformer";

const uint8Matrix = () =>
  integer({ min: 1, max: 10 }).chain((width) =>
    integer({ min: 1, max: 10 }).chain((height) => {
      const size = width * height * NUM_CHANNELS;
      return uint8Array({ minLength: size, maxLength: size }).map((array) => {
        const matrix = new WebGlInputMatrix(width, height);
        matrix.asArray().set(array);
        return matrix;
      });
    })
  );

const fragmentShaderSetup = `\
    precision mediump float;

    uniform sampler2D input_state;
    uniform vec2 resolution;
    `;

describe("WebGLMatrixTransformer", () => {
  describe("transform", () => {
    it("should act as the identity when supplied with a copy-xy fragment shader", () => {
      const transformer = new WebGlMatrixTransformer(`\
            ${fragmentShaderSetup}

            void main() {
                gl_FragColor = texture2D(input_state, gl_FragCoord.xy / resolution);
            }
            `);

      assert(
        property(uint8Matrix(), (matrix) => {
          const transformed = transformer.transform(matrix).asArray();

          const expected = WebGlOutputMatrix.ofMinSize(matrix);
          expected.forEach((_, index) => {
            expected.set(index, matrix.get(index));
          });
          expect(transformed).toEqual(expected.asArray());
        })
      );
    });

    it("should flip cells over the line y=x when supplied with a flip-xy fragment shader", () => {
      const transformer = new WebGlMatrixTransformer(`\
            ${fragmentShaderSetup}

            void main() {
                gl_FragColor = texture2D(input_state, gl_FragCoord.yx / resolution);
            }
            `);

      const input = new WebGlInputMatrix(2, 2);
      input.set(vec2(0, 0), vec4(1, 1, 1, 1));
      input.set(vec2(1, 0), vec4(2, 2, 2, 2));
      input.set(vec2(0, 1), vec4(3, 3, 3, 3));
      input.set(vec2(1, 1), vec4(4, 4, 4, 4));

      const expected = new WebGlOutputMatrix(2, 2);
      expected.set(vec2(0, 0), vec4(1, 1, 1, 1));
      expected.set(vec2(1, 0), vec4(3, 3, 3, 3));
      expected.set(vec2(0, 1), vec4(2, 2, 2, 2));
      expected.set(vec2(1, 1), vec4(4, 4, 4, 4));

      const transformed = transformer.transform(input).asArray();

      expect(transformed).toEqual(expected.asArray());
    });

    it("should slide cells one to the right, filling the leftmost cells with zero when supplied with an (x,y) -> (x-1,y) fragment shader", () => {
      const transformer = new WebGlMatrixTransformer(`\
            ${fragmentShaderSetup}

            vec4 getOrDefault(vec2 diff) {
              vec2 index = (gl_FragCoord.xy + diff) / resolution;
              if ((index.x < 0.0 || 1.0 < index.x) || (index.y < 0.0 || 1.0 < index.y)) {
                return vec4(0.0, 0.0, 0.0, 0.0);
              }
              return texture2D(input_state, index);
            }

            void main() {
                gl_FragColor = getOrDefault(vec2(-1.0, 0.0));
            }
            `);

      const input = new WebGlInputMatrix(2, 1);
      input.set(vec2(0, 0), vec4(1, 1, 1, 1));
      input.set(vec2(1, 0), vec4(2, 2, 2, 2));

      const expected = new WebGlOutputMatrix(2, 1);
      expected.set(vec2(0, 0), vec4(0, 0, 0, 0));
      expected.set(vec2(1, 0), vec4(1, 1, 1, 1));

      const transformed = transformer.transform(input).asArray();

      expect(transformed).toEqual(expected.asArray());
    });

    it("should return a matrix containing (x, 0, 0, 0) in each cell when supplied with a fragment shader which extracts the x-component of the input", () => {
      const transformer = new WebGlMatrixTransformer(`\
            ${fragmentShaderSetup}

            void main() {
                gl_FragColor = vec4(texture2D(input_state, gl_FragCoord.xy / resolution).x, 0.0, 0.0, 0.0);
            }
            `);

      assert(
        property(uint8Matrix(), (matrix) => {
          const expected = WebGlOutputMatrix.ofMinSize(matrix);
          expected.forEach((_, index) => {
            const value = matrix.get(index);
            expected.set(index, vec4(value.x, 0, 0, 0));
          });
          const transformed = transformer.transform(matrix).asArray();
          expect(transformed).toEqual(expected.asArray());
        })
      );
    });

    it("should act as the identity on a matrix which is larger than the default viewport size when supplied with a copy-xy fragment shader", () => {
      const transformer = new WebGlMatrixTransformer(`\
        ${fragmentShaderSetup}

        void main() {
            gl_FragColor = texture2D(input_state, gl_FragCoord.xy / resolution);
        }
        `);

      // The canvas is 300x150 by default, so 152 is just slightly taller than the viewport.
      // Unless the WebGL viewport is properly resized to accommodate this matrix, the
      // bottom two rows of the matrix will be ignored because they do not fit into the WebGL
      // viewport.
      const input = new WebGlInputMatrix(1, 152);
      input.forEach((_, index) => {
        input.set(index, vec4(index.x, index.y, 3, 7));
      });

      const expected = new WebGlOutputMatrix(1, 152);
      expected.forEach((_, index) => {
        expected.set(index, vec4(index.x, index.y, 3, 7));
      });

      const transformed = transformer.transform(input).asArray();

      expect(transformed).toEqual(expected.asArray());
    });
  });
});
