export const fromPage = (cellSizeInPixels: number) => (bound: number) =>
  Math.floor(bound / cellSizeInPixels);

export const toPage = (cellSizeInPixels: number) => (bound: number) =>
  Math.floor(bound * cellSizeInPixels);
