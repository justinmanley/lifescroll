import { LifeGridVector2 } from "../../ts-src/life/coordinates/vector2";
import { GameOfLife } from "../../ts-src/life/game-of-life";
import { oscillators } from "./testdata/oscillator";
import { stillLives } from "./testdata/still-life";
import { assert, property, integer } from "fast-check";
import { spaceships } from "./testdata/spaceship";

describe("GameOfLife", () => {
  describe("still lives", () => {
    for (const stillLife of stillLives) {
      it(`should keep the ${stillLife.name} the same`, () => {
        const life = new GameOfLife();

        expect(life.next(stillLife.cells)).toEqual(stillLife.cells);
      });
    }
  });

  describe("oscillators", () => {
    for (const oscillator of oscillators) {
      it(`should keep the ${oscillator.name} the same when evolved for the oscillator's period`, () => {
        const life = new GameOfLife();

        const result = loop(
          (cells: LifeGridVector2[]) => life.next(cells),
          oscillator.cells,
          oscillator.period
        );

        expect(result).toEqual(oscillator.cells);
      });

      it(`should be different from the ${oscillator.name}'s initial state when evolved for less than its period`, () => {
        assert(
          property(integer({ min: 1, max: oscillator.period - 1 }), (steps) => {
            const life = new GameOfLife();

            const result = loop(
              (cells: LifeGridVector2[]) => life.next(cells),
              oscillator.cells,
              steps
            );

            expect(result).not.toEqual(oscillator.cells);
          })
        );
      });
    }
  });

  describe("spaceships", () => {
    for (const spaceship of spaceships) {
      const name = spaceship.name;
      const period = spaceship.movement.period;
      const direction = spaceship.movement.direction.toString();

      it(`should displace the ${name} by ${direction} after ${period} steps`, () => {
        const life = new GameOfLife();

        const result = loop(
          (cells: LifeGridVector2[]) => life.next(cells),
          spaceship.cells,
          period
        );

        expect(result).toEqual(
          spaceship.cells.map(
            (cell) =>
              new LifeGridVector2(
                cell.x + spaceship.movement.direction.x,
                cell.y + spaceship.movement.direction.y
              )
          )
        );
      });
    }
  });
});

const loop = <T>(fn: (input: T) => T, initialValue: T, times: number): T => {
  return times === 0 ? initialValue : loop(fn, fn(initialValue), times - 1);
};
