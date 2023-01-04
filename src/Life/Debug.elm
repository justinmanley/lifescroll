module Life.Debug exposing (..)

import BoundingRectangle exposing (BoundingRectangle)
import Canvas exposing (Renderable, Shape, lineTo, path, shapes)
import Canvas.Settings exposing (stroke)
import Canvas.Settings.Advanced exposing (transform, translate)
import Canvas.Settings.Line exposing (lineWidth)
import Color exposing (Color)
import PatternAnchor exposing (PatternAnchor)


debugStrokeHalfWidth : number
debugStrokeHalfWidth =
    2


renderGrid : BoundingRectangle Float -> Float -> BoundingRectangle Float -> Renderable
renderGrid viewport cellSize page =
    let
        verticalLine : Float -> Shape
        verticalLine x =
            path
                ( cellSize * x - debugStrokeHalfWidth, cellSize * page.top )
                [ lineTo ( cellSize * x - debugStrokeHalfWidth, cellSize * page.bottom ) ]

        horizontalLine : Float -> Shape
        horizontalLine y =
            path
                ( cellSize * page.left, cellSize * y - debugStrokeHalfWidth )
                [ lineTo ( cellSize * page.right, cellSize * y - debugStrokeHalfWidth ) ]

        verticalLines : List Shape
        verticalLines =
            List.map (verticalLine << toFloat) <|
                List.range 0 (ceiling <| BoundingRectangle.width page / cellSize)

        horizontalLines : List Shape
        horizontalLines =
            List.map (horizontalLine << toFloat) <|
                List.range 0 (ceiling <| BoundingRectangle.height page / cellSize)
    in
    shapes
        [ stroke Color.darkGray
        , lineWidth (debugStrokeHalfWidth * 2)
        , transform [ translate -viewport.left -viewport.top ]
        ]
    <|
        List.append verticalLines horizontalLines


renderLayoutRegions : BoundingRectangle Float -> List PatternAnchor -> Renderable
renderLayoutRegions viewport anchors =
    let
        renderLayoutRegion : PatternAnchor -> Shape
        renderLayoutRegion anchor =
            Canvas.rect
                ( anchor.bounds.left
                , anchor.bounds.top
                )
                (BoundingRectangle.width anchor.bounds)
                (BoundingRectangle.height anchor.bounds)
    in
    shapes
        [ stroke Color.blue
        , lineWidth
            (debugStrokeHalfWidth * 2)
        , transform [ translate -viewport.left -viewport.top ]
        ]
    <|
        List.map renderLayoutRegion anchors


renderGridBounds : BoundingRectangle Float -> Float -> Color -> List (BoundingRectangle Int) -> Renderable
renderGridBounds viewport cellSize color gridBoundingRectangles =
    let
        gridBoundsShape : BoundingRectangle Int -> Shape
        gridBoundsShape bounds =
            Canvas.rect
                ( toFloat bounds.left * cellSize - debugStrokeHalfWidth
                , toFloat bounds.top * cellSize - debugStrokeHalfWidth
                )
                (toFloat (BoundingRectangle.width bounds) * cellSize + debugStrokeHalfWidth)
                (toFloat (BoundingRectangle.height bounds) * cellSize + debugStrokeHalfWidth)
    in
    shapes
        [ stroke color
        , lineWidth
            (debugStrokeHalfWidth * 2)
        , transform [ translate -viewport.left -viewport.top ]
        ]
    <|
        List.map gridBoundsShape gridBoundingRectangles
