interface BoundingRectangleParams {
  top: number;
  left: number;
  bottom: number;
  right: number;
}

export class BoundingRectangle {
  public readonly width: number;
  public readonly height: number;

  constructor(private params: BoundingRectangleParams) {
    this.width = params.right - params.left;
    this.height = params.bottom - params.top;
  }

  static empty(): BoundingRectangle {
    return new BoundingRectangle({
      top: 0,
      left: 0,
      bottom: 0,
      right: 0,
    });
  }

  map(fn: (value: number) => number): BoundingRectangle {
    return new BoundingRectangle({
      top: fn(this.top),
      left: fn(this.left),
      bottom: fn(this.bottom),
      right: fn(this.right),
    });
  }

  get top() {
    return this.params.top;
  }

  get left() {
    return this.params.left;
  }

  get bottom() {
    return this.params.bottom;
  }

  get right() {
    return this.params.right;
  }
}
