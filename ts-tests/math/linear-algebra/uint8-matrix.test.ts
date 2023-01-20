import { Uint8Matrix } from "../../../ts-src/math/linear-algebra/uint8-matrix";
import { assert, property, integer, nat, array, tuple } from "fast-check";

const uint8 = () => integer({ min: -128, max: 127 });

const sparseUint8Matrix = () => {
  return integer({ min: 1, max: 10 }).chain((width) => {
    return integer({ min: 1, max: 10 }).chain((height) => {
      return integer({ min: 1, max: 10 }).chain((num_channels) => {
        return array(
          tuple(
            nat(width - 1),
            nat(height - 1),
            nat(num_channels - 1),
            uint8()
          ),
          { maxLength: 10 }
        ).map((values) => {
          return {
            width,
            height,
            num_channels,
            values,
          };
        });
      });
    });
  });
};

describe("Uint8Matrix", () => {
  it("the value returned by .get() matches the value returned by .forEach()", () => {
    assert(
      property(
        sparseUint8Matrix(),
        ({ width, height, num_channels, values }) => {
          const matrix = new Uint8Matrix(width, height, num_channels);

          // This effectively tests that toMatrixIndex and fromMatrixIndex are inverses.
          values.forEach(([x, y, z, value]) => {
            matrix.set({ x, y, z }, value);
          });

          matrix.forEach((value, index) => {
            expect(matrix.get(index)).toEqual(value);
          });
        }
      )
    );
  });
});
