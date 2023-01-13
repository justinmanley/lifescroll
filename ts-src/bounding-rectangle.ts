interface BoundingRectangleParams {
    top: number;
    left: number;
    bottom: number;
    right: number;
}

export class BoundingRectangle {
    constructor(private params: BoundingRectangleParams) {
    }

    static empty(): BoundingRectangle {
        return new BoundingRectangle({
            top: 0,
            left: 0,
            bottom: 0,
            right: 0
        })
    }
}