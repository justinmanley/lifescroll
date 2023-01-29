import { LifeGridBoundingRectangle } from "../coordinates/bounding-rectangle";
import { BoundingRectangleEdgeMovements } from "./bounding-rectangle-edge-movements";
import { Movement } from "./movement";

interface Update {
  stepsElapsed: number;
  movement?: Movement;
  edgeMovements?: BoundingRectangleEdgeMovements;
}

export class AtomicUpdateBounds {
  constructor(public readonly rectangle: LifeGridBoundingRectangle) {}

  next({ stepsElapsed, movement, edgeMovements }: Update): AtomicUpdateBounds {
    return this.move(stepsElapsed, movement).moveEdges(
      stepsElapsed,
      edgeMovements
    );
  }

  private move(stepsElapsed: number, movement?: Movement): AtomicUpdateBounds {
    return new AtomicUpdateBounds(
      movement && stepsElapsed % movement.period === 0
        ? this.rectangle.offset(movement.direction)
        : this.rectangle
    );
  }

  private moveEdges(
    steps: number,
    movements?: BoundingRectangleEdgeMovements
  ): AtomicUpdateBounds {
    const bounds = this.rectangle;
    return new AtomicUpdateBounds(
      new LifeGridBoundingRectangle({
        top: movements?.top?.move(bounds.top, steps) ?? bounds.top,
        left: movements?.left?.move(bounds.left, steps) ?? bounds.left,
        bottom: movements?.bottom?.move(bounds.bottom, steps) ?? bounds.bottom,
        right: movements?.right?.move(bounds.right, steps) ?? bounds.right,
      })
    );
  }
}
