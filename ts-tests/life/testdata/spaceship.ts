import { vec2, Vector2 } from "../../../ts-src/math/linear-algebra/vector2";
import { toLifeGridPositions } from "./pattern";

interface Spaceship<T> {
  name: string;
  cells: T[];
  movement: {
    direction: Vector2;
    period: number;
  };
}

const spaceshipCells: Spaceship<[number, number]>[] = [
  {
    name: "glider",
    cells: [
      [0, 0],
      [1, 0],
      [1, 2],
      [2, 0],
      [2, 1],
    ],
    movement: {
      direction: vec2(1, -1),
      period: 4,
    },
  },
  {
    name: "lightweight spaceship",
    cells: [
      [0, 1],
      [0, 3],
      [1, 0],
      [2, 0],
      [3, 0],
      [3, 3],
      [4, 0],
      [4, 1],
      [4, 2],
    ],
    movement: {
      direction: vec2(2, 0),
      period: 4,
    },
  },
];

export const spaceships = spaceshipCells.map(toLifeGridPositions);
