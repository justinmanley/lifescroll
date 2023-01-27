import { BoundingRectangle } from "../math/geometry/bounding-rectangle";
import { LifeGridBoundingRectangle } from "./coordinates/bounding-rectangle";
import { LifeGridVector2 } from "./coordinates/vector2";
import { LaidOutPattern } from "./pattern";
import { GameOfLife } from "./game-of-life";
import { AtomicUpdateRegion } from "./pattern-rendering-options/atomic-update-region";
import { LifeGridInterval } from "./coordinates/interval";
import { partition } from "lodash";

export interface LayoutParams {
  full: BoundingRectangle;
  center: BoundingRectangle;
  cellSizeInPixels: number;
}

export interface LifeState {
  cells: LifeGridVector2[];
  atomicUpdateRegions: AtomicUpdateRegion[];
}

const NUM_PROTECTED_BOTTOM_GRID_CELLS = 6;

export class ScrollingGameOfLife {
  private cells: LifeGridVector2[];
  private atomicUpdateRegions: AtomicUpdateRegion[];
  private rule: GameOfLife;

  constructor(patterns: LaidOutPattern[]) {
    this.cells = ([] as LifeGridVector2[]).concat(
      ...patterns.map((pattern) => pattern.cells)
    );
    this.atomicUpdateRegions = ([] as AtomicUpdateRegion[]).concat(
      ...patterns.map((pattern) => pattern.atomicUpdateRegions)
    );
    this.rule = new GameOfLife();
  }

  public scroll(viewport: LifeGridBoundingRectangle): LifeState {
    const steppable = this.steppableVerticalBounds(viewport);

    const [steppableRegions, notSteppableRegions] = partition(
      this.atomicUpdateRegions,
      (atomicUpdateRegion) => atomicUpdateRegion.isSteppable(steppable)
    );

    // Note that it is possible for a pattern to be corrupted if that pattern
    // is straddling the boundary of the steppable viewport and belongs to BOTH
    // an atomic update region with criterion AnyIntersectionWithSteppableRegion
    // and another atomic update region with FullyContainedWithinSteppableRegion.
    // In this case, the cells within the atomic update region inside the viewport
    // will not be updated, while the cells within the atomic update region outside
    // the viewport will be updated.
    // TODO: Handle this proactively by preventing incompatible overlapping
    // atomicUpdateRegions (but: what to do when they overlap? convert one into
    // the other type?
    const isCellSteppable = (cell: LifeGridVector2): boolean => {
      const containsCell = (atomicUpdateRegion: AtomicUpdateRegion): boolean =>
        atomicUpdateRegion.bounds.some((bounds) => bounds.contains(cell));
      return steppable.contains(cell.y)
        ? !notSteppableRegions.some(containsCell)
        : steppableRegions.some(containsCell);
    };

    const [steppableCells, notSteppableCells] = partition(
      this.cells,
      isCellSteppable
    );

    if (steppableCells.length > 0) {
      this.cells = [...this.rule.next(steppableCells), ...notSteppableCells];
      this.atomicUpdateRegions = [
        ...steppableRegions.map((region) => region.next()),
        ...notSteppableRegions,
      ];
    }

    return {
      cells: this.cells,
      atomicUpdateRegions: this.atomicUpdateRegions,
    };
  }

  private steppableVerticalBounds(
    viewport: LifeGridBoundingRectangle
  ): LifeGridInterval {
    const viewportVertical = viewport.vertical();
    return new LifeGridInterval(
      viewportVertical.start,
      viewportVertical.end - NUM_PROTECTED_BOTTOM_GRID_CELLS
    );
  }
}
