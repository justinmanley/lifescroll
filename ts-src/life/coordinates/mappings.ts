export const fromPage = (cellSizeInPixels: number) => (bound: number) =>
  bound / cellSizeInPixels;

export const toPage = (cellSizeInPixels: number) => (bound: number) =>
  bound * cellSizeInPixels;
