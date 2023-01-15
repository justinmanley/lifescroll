export class JsonMissingFieldError extends Error {
  constructor(object: object, field: string) {
    super(`Expected object ${JSON.stringify(object)} to have field ${field}.`);
  }
}

export class JsonWrongTypeError extends Error {
  constructor(value: unknown, type: string) {
    super(`Expected value ${JSON.stringify(value)} to be of type ${type}.`);
  }
}
