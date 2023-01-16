export class DebugSettings {
  public readonly atomicUpdates: boolean = false;
  public readonly layout: boolean = false;
  public readonly grid: boolean = false;
  public readonly log: boolean = false;

  constructor() {
    const params = new Proxy(new URLSearchParams(window.location.search), {
      get: (searchParams: URLSearchParams, prop: string) =>
        searchParams.get(prop),
    });

    // @ts-ignore (why is this necessary?)
    const debug = params.debug;
    if (!debug) {
      return;
    }

    this.atomicUpdates = debug.includes("atomic-updates");
    this.layout = debug.includes("layout");
    this.grid = debug.includes("grid");
    this.log = debug.includes("log");
  }
}
