import {
  Parser,
  alt,
  oneOf,
  eof,
  end,
  regexp,
  fail,
  succeed,
  newline,
} from "parsimmon";
import { continueLoop, done, loop, Step } from "../parsing/loop";
import { int } from "../parsing/int";
import { range } from "lodash";

type Coordinates = [number, number][];

export const parse = (input: string): Coordinates => {
  return loop(line, new State()).tryParse(input);
};

const line = (state: State): Parser<Step<State, Coordinates>> =>
  alt(
    eof.map(() => done(state.getCoordinates())),
    alt(
      extent.map(() => continueLoop<State, Coordinates>(state)),
      comment.map(() => continueLoop<State, Coordinates>(state)),
      coordinates(state).map(continueLoop<State, Coordinates>)
    ).chain((s) => end.result(s))
  );

const extent: Parser<unknown> = regexp(
  /x = \d+, y = \d+(, rule = [bB]3\/[sS]23)?/
);

const comment: Parser<unknown> = regexp(/#.*/);

enum RleToken {
  Dead,
  Alive,
  NextLine,
  End,
}
const { Dead, Alive, NextLine, End } = RleToken;

const coordinates = (state: State): Parser<State> => loop(coordinate, state);

const coordinate = (state: State): Parser<Step<State, State>> =>
  alt(
    alt(int, succeed(1)).chain((num) =>
      rleToken.chain((token) => {
        if (token === End) {
          if (state.isCompleted()) {
            return fail("Pattern contains multiple exclamation points (!).");
          }
          return succeed(done(state.decodeRle(token, num)));
        }
        return succeed(continueLoop<State, State>(state.decodeRle(token, num)));
      })
    ),
    newline.result(state).map(continueLoop<State, State>),
    eof.result(state).map(done<State, State>)
  );

const rleToken: Parser<RleToken> = oneOf("bo$!").chain((char) => {
  switch (char) {
    case "b":
      return succeed(Dead);
    case "o":
      return succeed(Alive);
    case "$":
      return succeed(NextLine);
    case "!":
      return succeed(End);
    default:
      return fail(`Unexpected character '${char}' while parsing an RLE token.`);
  }
});

class State {
  private cursor: {
    x: number;
    y: number;
  } = { x: 0, y: 0 };
  private completed: boolean = false;
  private coordinates: Coordinates = [];

  decodeRle(token: RleToken, num: number): this {
    switch (token) {
      case Dead:
        this.cursor.x += num;
        break;
      case Alive:
        const xs = range(this.cursor.x, this.cursor.x + num);
        this.coordinates = this.coordinates.concat(
          xs.map((x) => [x, this.cursor.y])
        );
        this.cursor.x += num;
        break;
      case NextLine:
        this.cursor = {
          x: 0,
          y: this.cursor.y + num,
        };
        break;
      case End:
        this.completed = true;
        break;
    }

    return this;
  }

  isCompleted(): boolean {
    return this.completed;
  }

  getCoordinates(): Coordinates {
    return this.coordinates;
  }
}
