import { Parser, digits, succeed, fail } from "parsimmon";

export const int: Parser<number> = digits.chain((result) => {
  const num = parseInt(result, 10);
  return Number.isNaN(num) ? fail(`'${num}' is not a number`) : succeed(num);
});
