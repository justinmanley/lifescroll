import { Size2 } from "../../math/geometry/size2";
import { fromPage, toPage } from "./mappings";
import { Decoder, number, struct, Functor } from "io-ts/Decoder";

export class LifeGridSize2 {
  constructor(public readonly width: number, public readonly height: number) {}

  static fromPage(pageSize2: Size2, cellSizeInPixels: number): LifeGridSize2 {
    const convert = fromPage(cellSizeInPixels);
    return new LifeGridSize2(
      convert(pageSize2.width),
      convert(pageSize2.height)
    );
  }

  toPage(cellSizeInPixels: number): Size2 {
    const convert = toPage(cellSizeInPixels);
    return new Size2(convert(this.width), convert(this.height));
  }

  map(fn: (value: number) => number): LifeGridSize2 {
    return new LifeGridSize2(fn(this.width), fn(this.height));
  }

  static decoder: Decoder<unknown, LifeGridSize2> = Functor.map(
    struct({ width: number, height: number }),
    ({ width, height }) => {
      return new LifeGridSize2(width, height);
    }
  );
}
