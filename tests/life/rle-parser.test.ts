import { parse } from "../../src/life/rle-parser";

describe("RLE parser", () => {
  describe("parse", () => {
    it("parses a single empty cell into an empty collection", () => {
      expect(parse("b!")).toHaveLength(0);
    });

    it("parses multiple empty cells into an empty collection", () => {
      expect(parse("3b!")).toHaveLength(0);
    });

    it("parses one live cell into a collection containing just the origin", () => {
      expect(parse("o!")).toEqual([[0, 0]]);
    });

    it("parses a row of multiple live cells into a collection of values with the same y-coordinate", () => {
      expect(parse("3o!")).toEqual([
        [0, 0],
        [1, 0],
        [2, 0],
      ]);
    });

    it("parses a combination of dead and live cells into a collection containing just the live cells", () => {
      expect(parse("3o2b!")).toEqual([
        [0, 0],
        [1, 0],
        [2, 0],
      ]);
    });

    it("parses multiple lines", () => {
      expect(parse("3o$obo!")).toEqual([
        [0, 0],
        [1, 0],
        [2, 0],
        [0, 1],
        [2, 1],
      ]);
    });

    it("parses blank lines", () => {
      expect(parse("o2$o!")).toEqual([
        [0, 0],
        [0, 2],
      ]);
    });

    it("succeeds even without trailing bang", () => {
      expect(parse("2o$ob")).toEqual([
        [0, 0],
        [1, 0],
        [0, 1],
      ]);
    });

    it("fails to parse an invalid string", () => {
      expect(() => parse("$#df%%fsd$!$$")).toThrow();
    });

    it("parses a comment to an empty collection", () => {
      expect(parse("#   ")).toHaveLength(0);
    });

    it("parses a comment and a newline to an empty collection", () => {
      expect(parse("#  ")).toHaveLength(0);
    });

    it("parses a comment with text to an empty collection", () => {
      expect(parse("# some stuff goes here")).toHaveLength(0);
    });

    it("parses multiple comments to an empty collection", () => {
      expect(parse("#  \n#  \n#   ")).toHaveLength(0);
    });

    it("parses cells, ignoring extent if present", () => {
      expect(parse("x = 2, y = 3\no!")).toEqual([[0, 0]]);
    });

    it("parses cells, ignoring extent and rule if present", () => {
      expect(parse("x = 2, y = 3, rule = b3/s23\no!")).toEqual([[0, 0]]);
    });

    it("parses cells, ignoring extent and comments if present", () => {
      expect(parse("# A comment\nx = 2, y = 3\nb2ob$o2bo$b2o!")).toEqual([
        [1, 0],
        [2, 0],
        [0, 1],
        [3, 1],
        [1, 2],
        [2, 2],
      ]);
    });

    it("ignores line breaks when parsing cells", () => {
      expect(parse("o\no!")).toEqual([
        [0, 0],
        [1, 0],
      ]);
    });

    it("fails to parse a pattern with two bangs", () => {
      expect(() => parse("o!\no!")).toThrow();
    });
  });
});
