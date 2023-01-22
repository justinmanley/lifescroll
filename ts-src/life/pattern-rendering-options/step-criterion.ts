import { Decoder, literal, Functor } from "io-ts/Decoder";

export enum StepCriterion {
  AnyIntersectionWithSteppableRegion,
  FullyContainedWithinSteppableRegion,
}

export const stepCriterionDecoder: Decoder<unknown, StepCriterion> =
  Functor.map(
    literal(
      "AnyIntersectionWithSteppableRegion",
      "FullyContainedWithinSteppableRegion"
    ),
    (value): StepCriterion => {
      switch (value) {
        case "AnyIntersectionWithSteppableRegion":
          return StepCriterion.AnyIntersectionWithSteppableRegion;
        case "FullyContainedWithinSteppableRegion":
          return StepCriterion.FullyContainedWithinSteppableRegion;
      }
    }
  );
