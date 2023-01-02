module Life.Life exposing (..)

import BoundingRectangle exposing (BoundingRectangle)
import Canvas exposing (Renderable, Shape, lineTo, path, shapes)
import Canvas.Settings exposing (fill, stroke)
import Canvas.Settings.Line exposing (lineWidth)
import Color
import Life.GridCells as GridCells exposing (GridCells)
import Life.Neighborhoods exposing (neighbors)
import Life.ProtectedRegion exposing (ProtectedRegion)
import Set
import Set.Extra as Set
import Size2 exposing (Size2)
import Vector2 exposing (Vector2, x, y)


type alias LifeGrid =
    { cells : GridCells
    , protected : List ProtectedRegion
    }


empty : LifeGrid
empty =
    { cells = GridCells.empty
    , protected = []
    }


resize : Size2 Int -> Size2 Int -> GridCells -> GridCells
resize oldSize newSize grid =
    let
        toCenteredInNewGrid : Vector2 Int -> Vector2 Int
        toCenteredInNewGrid position =
            ( x position - floor (toFloat newSize.width / 2)
            , y position - floor (toFloat newSize.height / 2)
            )

        fromCenteredInOldGrid : Vector2 Int -> Vector2 Int
        fromCenteredInOldGrid position =
            ( x position + floor (toFloat oldSize.width / 2)
            , y position + floor (toFloat oldSize.height / 2)
            )

        oldIndexToNewIndex : Vector2 Int -> Vector2 Int
        oldIndexToNewIndex =
            fromCenteredInOldGrid >> toCenteredInNewGrid
    in
    if newSize.width == oldSize.width && newSize.height == oldSize.height then
        grid

    else
        Set.map oldIndexToNewIndex grid



-- TODO: Consider rendering only the cells that are within the viewport +/- some margin
-- in order to reduce the painting cost.


render : Float -> GridCells -> Renderable
render cellSize cells =
    let
        square point size =
            Canvas.rect point size size

        renderCell : Vector2 Int -> Shape
        renderCell position =
            square
                ( toFloat (x position) * cellSize
                , toFloat (y position) * cellSize
                )
                cellSize
    in
    shapes [ fill Color.black ] <| List.map renderCell <| Set.toList cells


debugStrokeHalfWidth =
    2


renderGrid : Float -> BoundingRectangle Float -> Renderable
renderGrid cellSize page =
    let
        verticalLine : Float -> Shape
        verticalLine x =
            path ( cellSize * x - debugStrokeHalfWidth, cellSize * page.top )
                [ lineTo ( cellSize * x - debugStrokeHalfWidth, cellSize * page.bottom ) ]

        horizontalLine : Float -> Shape
        horizontalLine y =
            path ( cellSize * page.left, cellSize * y - debugStrokeHalfWidth )
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
    shapes [ stroke Color.darkGray, lineWidth (debugStrokeHalfWidth * 2) ] <|
        List.append verticalLines horizontalLines


renderProtectedRegions : Float -> List ProtectedRegion -> Renderable
renderProtectedRegions cellSize protectedRegions =
    let
        renderRegion : ProtectedRegion -> Shape
        renderRegion { bounds } =
            Canvas.rect
                ( toFloat bounds.left * cellSize - debugStrokeHalfWidth
                , toFloat bounds.top * cellSize - debugStrokeHalfWidth
                )
                (toFloat (BoundingRectangle.width bounds) * cellSize + debugStrokeHalfWidth)
                (toFloat (BoundingRectangle.height bounds) * cellSize + debugStrokeHalfWidth)
    in
    shapes [ stroke Color.red, lineWidth (debugStrokeHalfWidth * 2) ] <|
        List.map renderRegion protectedRegions


next : GridCells -> GridCells
next grid =
    let
        adjacentDeadCells =
            Set.diff (Set.flatMap neighbors grid) grid

        newborns =
            Set.filter (shouldBeBorn grid) adjacentDeadCells

        survivors =
            Set.filter (shouldSurvive grid) grid
    in
    Set.union survivors newborns



-- Only used to advance to the next generation.


countLiveNeighbors : GridCells -> Vector2 Int -> Int
countLiveNeighbors aliveCells cell =
    Set.filter (\c -> Set.member c aliveCells) (neighbors cell) |> Set.size


shouldSurvive : GridCells -> Vector2 Int -> Bool
shouldSurvive aliveCells aliveCell =
    let
        aliveNeighbors =
            countLiveNeighbors aliveCells aliveCell
    in
    aliveNeighbors == 2 || aliveNeighbors == 3


shouldBeBorn : GridCells -> Vector2 Int -> Bool
shouldBeBorn aliveCells deadCell =
    let
        aliveNeighbors =
            countLiveNeighbors aliveCells deadCell
    in
    aliveNeighbors == 3
