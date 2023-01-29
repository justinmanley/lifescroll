import { Size3 } from "../geometry/size3";
import { Vector3 } from "./vector3";

export class Uint8Matrix {
  private readonly array: Uint8Array;

  constructor(
    private readonly width: number,
    private readonly height: number,
    private readonly elementSize: number
  ) {
    this.array = new Uint8Array(width * height * elementSize);
  }

  forEach(fn: (value: number, index: Vector3) => void): void {
    this.array.forEach((value, index) => {
      fn(value, this.toMatrixIndex(index));
    });
  }

  set(index: Vector3, value: number) {
    this.array[this.fromMatrixIndex(index)] = value;
  }

  get(index: Vector3): number {
    return this.array[this.fromMatrixIndex(index)];
  }

  asArray() {
    return this.array;
  }

  size(): Size3 {
    return new Size3(this.width, this.height, this.elementSize);
  }

  static ofSize(size: Size3): Uint8Matrix {
    return new Uint8Matrix(size.width, size.height, size.depth);
  }

  private toMatrixIndex(index: number): Vector3 {
    return {
      x: Math.floor(index / this.elementSize) % this.width,
      y: Math.floor(index / (this.width * this.elementSize)),
      z: index % this.elementSize,
    };
  }

  private fromMatrixIndex({ x, y, z }: Vector3) {
    return (this.width * y + x) * this.elementSize + z;
  }
}
