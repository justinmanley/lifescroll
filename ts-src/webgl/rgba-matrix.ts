import { Size2 } from "../math/geometry/size2";
import { Uint8Matrix } from "../math/linear-algebra/uint8-matrix";
import { vec2, Vector2 } from "../math/linear-algebra/vector2";
import { Vector4 } from "../math/linear-algebra/vector4";

export const NUM_CHANNELS = 4; // RGBA

// Avoid using Vector2 directly so that callers can pass anything
// which has fields called 'x' and 'y.'
interface MatrixIndex {
  x: number;
  y: number;
}

export class RgbaMatrix {
  private matrix: Uint8Matrix;

  public readonly size: Size2;

  constructor(public readonly width: number, public readonly height: number) {
    this.matrix = new Uint8Matrix(width, height, NUM_CHANNELS);
    this.size = new Size2(width, height);
  }

  get({ x, y }: MatrixIndex): Vector4 {
    return new Vector4(
      this.matrix.get({ x, y, z: 0 }),
      this.matrix.get({ x, y, z: 1 }),
      this.matrix.get({ x, y, z: 2 }),
      this.matrix.get({ x, y, z: 3 })
    );
  }

  set({ x, y }: MatrixIndex, value: Vector4) {
    this.matrix.set({ x, y, z: 0 }, value.x);
    this.matrix.set({ x, y, z: 1 }, value.y);
    this.matrix.set({ x, y, z: 2 }, value.z);
    this.matrix.set({ x, y, z: 3 }, value.w);
  }

  asArray(): Uint8Array {
    return this.matrix.asArray();
  }

  forEach(fn: (value: Vector4, index: Vector2) => void): void {
    for (let x = 0; x < this.width; x++) {
      for (let y = 0; y < this.height; y++) {
        const index = vec2(x, y);
        fn(this.get(index), index);
      }
    }
  }

  map(fn: (value: Vector4, index: Vector2) => Vector4): RgbaMatrix {
    const result = RgbaMatrix.ofSize(this.size);
    for (let x = 0; x < this.width; x++) {
      for (let y = 0; y < this.height; y++) {
        const index = vec2(x, y);
        result.set(index, fn(this.get(index), index));
      }
    }
    return result;
  }

  static ofSize(size: { width: number; height: number }): RgbaMatrix {
    return new RgbaMatrix(size.width, size.height);
  }
}
