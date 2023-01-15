import { LifeGridPosition } from "./coordinates/position";
import { PatternRenderingOptions } from "./pattern-rendering-options/pattern-rendering-options";

export interface Pattern {
  id: string;
  cells: LifeGridPosition[];
  renderingOptions: PatternRenderingOptions;
}
