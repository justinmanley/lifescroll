import { LifeGridPosition } from "../../../ts-src/life/coordinates/position";

type Pattern<T, S> = {
  cells: T[];
} & S;

export const toLifeGridPositions = <S>(
  pattern: Pattern<[number, number], S>
): Pattern<LifeGridPosition, S> => ({
  ...pattern,
  cells: pattern.cells.map(LifeGridPosition.fromTuple),
});
