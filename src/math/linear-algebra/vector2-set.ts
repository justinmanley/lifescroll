interface XY {
  x: number;
  y: number;
}

export class Vector2Set<T extends XY> {
  private xsToYs: Map<number, Set<number>> = new Map();

  constructor(vectors: T[] = []) {
    this.addAll(vectors);
  }

  addAll(vectors: T[]) {
    vectors.forEach(({ x, y }) => {
      const ys = this.xsToYs.get(x);
      if (!ys) {
        this.xsToYs.set(x, new Set([y]));
      } else {
        ys.add(y);
      }
    });
  }

  asArray(Constructor: new (x: number, y: number) => T): T[] {
    const vectors: T[] = [];
    this.xsToYs.forEach((ys, x) => {
      ys.forEach((y) => {
        vectors.push(new Constructor(x, y));
      });
    });
    return vectors;
  }
}
