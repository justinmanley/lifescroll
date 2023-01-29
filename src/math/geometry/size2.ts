import { Vector2 } from "../linear-algebra/vector2";

export class Size2 extends Vector2 {
  constructor(public readonly width: number, public readonly height: number) {
    super(width, height);
  }
}
