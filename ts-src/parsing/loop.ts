import { Parser, succeed } from "parsimmon";

enum LoopInstruction {
  Continue,
  Done,
}
const { Continue, Done } = LoopInstruction;

export type Step<State, Value> =
  | {
      type: LoopInstruction.Continue;
      continue: State;
    }
  | {
      type: LoopInstruction.Done;
      done: Value;
    };

// Use a function because TypeScript generics do not work on arrow functions.
// TODO: Consider writing this as a while-loop to improve performance.
export function loop<State, Value>(
  fn: (state: State) => Parser<Step<State, Value>>,
  state: State
): Parser<Value> {
  return fn(state).chain((step) => {
    switch (step.type) {
      case Continue:
        return loop(fn, step.continue);
      case Done:
        return succeed(step.done);
    }
  });
}

export function done<State, Value>(value: Value): Step<State, Value> {
  return {
    type: Done,
    done: value,
  };
}

export function continueLoop<State, Value>(state: State): Step<State, Value> {
  return {
    type: Continue,
    continue: state,
  };
}
