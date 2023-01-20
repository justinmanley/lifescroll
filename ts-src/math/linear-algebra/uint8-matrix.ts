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
      x: Math.floor(index / (this.height * this.elementSize)),
      y: Math.floor(index / this.elementSize) % this.height,
      z: index % this.elementSize,
    };

    /*
    return {
      x: Math.floor(index / this.elementSize) % this.height,
      y: Math.floor(index / (this.height * this.elementSize)),
      z: index % this.elementSize,
    };

    return {
      x: index % this.width,
      y: Math.floor(index / this.width) % this.height,
      z: Math.floor(index / (this.width * this.height)),
    };
    */
  }

  private fromMatrixIndex({ x, y, z }: Vector3) {
    return (this.height * x + y) * this.elementSize + z;

    /*
    return x + this.width * y + this.width * this.height * channel;
    */
  }
}
