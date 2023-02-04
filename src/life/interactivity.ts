import { Decoder, literal, Functor } from "io-ts/Decoder";
import { Vector2 } from "../math/linear-algebra/vector2";

export enum Interactivity {
  None,
  WithinPatternAnchorsOnly,
  WithinScrollingGameOfLife,
  FullPage,
}

type ClickHandlingPredicate = (position: Vector2) => boolean;

export interface ClickHandlingPredicates {
  [Interactivity.None]: ClickHandlingPredicate;
  [Interactivity.WithinPatternAnchorsOnly]: ClickHandlingPredicate;
  [Interactivity.WithinScrollingGameOfLife]: ClickHandlingPredicate;
  [Interactivity.FullPage]: ClickHandlingPredicate;
}

export const interactivityDecoder: Decoder<unknown, Interactivity> =
  Functor.map(
    literal("none", "pattern-anchors", "this", "full"),
    (value): Interactivity => {
      switch (value) {
        case "none":
          return Interactivity.None;
        case "pattern-anchors":
          return Interactivity.WithinPatternAnchorsOnly;
        case "this":
          return Interactivity.WithinScrollingGameOfLife;
        case "full":
          return Interactivity.FullPage;
      }
    }
  );
