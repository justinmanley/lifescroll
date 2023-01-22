import { LifeGridVector2 } from "../../../ts-src/life/coordinates/vector2";
import { toLifeGridVector2s } from "./pattern";

interface StillLife<T> {
  name: string;
  cells: T[];
}

const stillLivesCells: StillLife<[number, number]>[] = [
  {
    name: "block",
    cells: [
      [0, 0],
      [0, 1],
      [1, 0],
      [1, 1],
    ],
  },
  {
    name: "beehive",
    cells: [
      [0, 1],
      [1, 0],
      [1, 2],
      [2, 0],
      [2, 2],
      [3, 1],
    ],
  },
];

export const stillLives: StillLife<LifeGridVector2>[] =
  stillLivesCells.map(toLifeGridVector2s);
