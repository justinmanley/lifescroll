export class Vector4 {
  constructor(
    public readonly x: number,
    public readonly y: number,
    public readonly z: number,
    public readonly w: number
  ) {}
}

export const vec4 = (x: number, y: number, z: number, w: number) =>
  new Vector4(x, y, z, w);
