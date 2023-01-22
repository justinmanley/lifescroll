import { LifeGridVector2 } from "../../../ts-src/life/coordinates/vector2";
import { toLifeGridVector2s } from "./pattern";

interface Oscillator<T> {
  name: string;
  cells: T[];
  period: number;
}

const oscillatorsCells: Oscillator<[number, number]>[] = [
  {
    name: "blinker",
    cells: [
      [0, 0],
      [0, 1],
      [0, 2],
    ],
    period: 2,
  },
  {
    name: "pentadecathlon",
    // Represents the Pentadecathlon in this phase:
    //     o    o
    //   oo oooo oo
    //     o    o
    cells: [
      [0, 1],
      [1, 1],
      [2, 0],
      [2, 2],
      [3, 1],
      [4, 1],
      [5, 1],
      [6, 1],
      [7, 0],
      [7, 2],
      [8, 1],
      [9, 1],
    ],
    period: 15,
  },
];

export const oscillators: Oscillator<LifeGridVector2>[] =
  oscillatorsCells.map(toLifeGridVector2s);
