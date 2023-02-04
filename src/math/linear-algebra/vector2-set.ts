interface XY {
  x: number;
  y: number;
}

interface Interval {
  contains: (value: number) => boolean;
}

export class Vector2Set<T extends XY> {
  private ysToXs: Map<number, Set<number>> = new Map();

  constructor(vectors: T[] = []) {
    this.addAll(vectors);
  }

  addAll(vectors: T[]) {
    vectors.forEach(({ x, y }) => {
      const xs = this.ysToXs.get(y);
      if (!xs) {
        this.ysToXs.set(y, new Set([x]));
      } else {
        xs.add(x);
      }
    });
  }

  withinVerticalRange(
    Constructor: new (x: number, y: number) => T,
    interval: Interval
  ) {
    return [...this.ysToXs.entries()]
      .filter(([y, _]) => interval.contains(y))
      .flatMap(([y, xs]) => [...xs].map((x) => new Constructor(x, y)));
  }
}
