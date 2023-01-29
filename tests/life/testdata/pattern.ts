import { LifeGridVector2 } from "../../../src/life/coordinates/vector2";

type Pattern<T, S> = {
  cells: T[];
} & S;

export const toLifeGridVector2s = <S>(
  pattern: Pattern<[number, number], S>
): Pattern<LifeGridVector2, S> => ({
  ...pattern,
  cells: pattern.cells.map(LifeGridVector2.fromTuple),
});
