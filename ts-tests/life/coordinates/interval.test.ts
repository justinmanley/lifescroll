import { LifeGridInterval } from "../../../ts-src/life/coordinates/interval";

describe("Interval", () => {
  describe("intersects", () => {
    it("should be true when two intervals overlap", () => {
      const a = new LifeGridInterval(0, 10);
      const b = new LifeGridInterval(5, 15);

      expect(a.intersects(b)).toBeTruthy();
      expect(b.intersects(a)).toBeTruthy();
    });

    it("should be false when two intervals do not overlap", () => {
      const a = new LifeGridInterval(0, 10);
      const b = new LifeGridInterval(20, 30);

      expect(a.intersects(b)).toBeFalsy();
      expect(b.intersects(a)).toBeFalsy();
    });
  });
});
