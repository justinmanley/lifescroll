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

const roundUpToNearestPowerOfTwo = (value: number) =>
  Math.pow(2, Math.ceil(Math.log2(value)));

abstract class WebGlMatrix {
  protected abstract matrix: Uint8Matrix;
  public abstract readonly size: Size2;

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
    for (let x = 0; x < this.size.width; x++) {
      for (let y = 0; y < this.size.height; y++) {
        const index = vec2(x, y);
        fn(this.get(index), index);
      }
    }
  }
}

/**
 * Represents a matrix whose dimensions are powers of two because
 * only power-of-two matrices work reliably on WebGL ES (i.e. mobile).
 */
export class WebGlInputMatrix extends WebGlMatrix {
  protected matrix: Uint8Matrix;
  public readonly size: Size2;
  public readonly minSize: Size2;

  constructor(
    public readonly minWidth: number,
    public readonly minHeight: number
  ) {
    super();
    this.minSize = new Size2(minWidth, minHeight);
    this.size = new Size2(
      roundUpToNearestPowerOfTwo(minWidth),
      roundUpToNearestPowerOfTwo(minHeight)
    );

    this.matrix = new Uint8Matrix(
      this.size.width,
      this.size.height,
      NUM_CHANNELS
    );
  }

  static ofSize(size: { width: number; height: number }): WebGlInputMatrix {
    return new WebGlInputMatrix(size.width, size.height);
  }
}

export class WebGlOutputMatrix extends WebGlMatrix {
  protected matrix: Uint8Matrix;
  public readonly size: Size2;

  constructor(width: number, height: number) {
    super();
    this.size = new Size2(width, height);
    this.matrix = new Uint8Matrix(
      this.size.width,
      this.size.height,
      NUM_CHANNELS
    );
  }

  static ofMinSize(matrix: WebGlInputMatrix): WebGlOutputMatrix {
    return new WebGlOutputMatrix(matrix.minWidth, matrix.minHeight);
  }
}
