import { JsonWrongTypeError } from "../../json/decoding";

export enum StepCriterion {
  AnyIntersectionWithSteppableRegion,
  FullyContainedWithinSteppableRegion,
}

export const decodeStepCriterion = (value: string): StepCriterion => {
  switch (value) {
    case "AnyIntersectionWithSteppableRegion":
      return StepCriterion.AnyIntersectionWithSteppableRegion;
    case "FullyContainedWithinSteppableRegion":
      return StepCriterion.FullyContainedWithinSteppableRegion;
  }

  throw new Error(`Unexpected value ${value} for step criterion.`);
};
