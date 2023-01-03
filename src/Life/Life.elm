module Life.Life exposing (..)

import BoundingRectangle exposing (BoundingRectangle)
import Canvas exposing (Renderable, Shape, lineTo, path, shapes)
import Canvas.Settings exposing (fill, stroke)
import Canvas.Settings.Line exposing (lineWidth)
import Color
import Life.AtomicUpdateRegion exposing (AtomicUpdateRegion)
import Life.GridCells as GridCells exposing (GridCells)
import Life.Neighborhoods exposing (neighbors)
import Set
import Set.Extra as Set
import Vector2 exposing (Vector2, x, y)


type alias LifeGrid =
    { cells : GridCells
    , atomicUpdateRegions : List AtomicUpdateRegion
    }


empty : LifeGrid
empty =
    { cells = GridCells.empty
    , atomicUpdateRegions = []
    }



-- TODO: Consider rendering only the cells that are within the viewport +/- some margin
-- in order to reduce the painting cost.


render : BoundingRectangle Float -> Float -> GridCells -> Renderable
render viewport cellSize cells =
    let
        square point size =
            Canvas.rect point size size

        renderCell : Vector2 Int -> Shape
        renderCell position =
            square
                ( toFloat (x position) * cellSize - viewport.left
                , toFloat (y position) * cellSize - viewport.top
                )
                cellSize
    in
    shapes [ fill Color.black ] <| List.map renderCell <| Set.toList cells


debugStrokeHalfWidth : number
debugStrokeHalfWidth =
    2


renderGrid : BoundingRectangle Float -> Float -> BoundingRectangle Float -> Renderable
renderGrid viewport cellSize page =
    let
        verticalLine : Float -> Shape
        verticalLine x =
            path
                ( cellSize * x - debugStrokeHalfWidth - viewport.left
                , cellSize * page.top - viewport.top
                )
                [ lineTo
                    ( cellSize * x - debugStrokeHalfWidth - viewport.left
                    , cellSize * page.bottom - viewport.top
                    )
                ]

        horizontalLine : Float -> Shape
        horizontalLine y =
            path
                ( cellSize * page.left - viewport.left
                , cellSize * y - debugStrokeHalfWidth - viewport.top
                )
                [ lineTo
                    ( cellSize * page.right - viewport.left
                    , cellSize * y - debugStrokeHalfWidth - viewport.top
                    )
                ]

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


renderAtomicUpdateRegions : BoundingRectangle Float -> Float -> List AtomicUpdateRegion -> Renderable
renderAtomicUpdateRegions viewport cellSize atomicUpdateRegions =
    let
        renderRegion : AtomicUpdateRegion -> Shape
        renderRegion { bounds } =
            Canvas.rect
                ( toFloat bounds.left * cellSize - debugStrokeHalfWidth - viewport.left
                , toFloat bounds.top * cellSize - debugStrokeHalfWidth - viewport.top
                )
                (toFloat (BoundingRectangle.width bounds) * cellSize + debugStrokeHalfWidth)
                (toFloat (BoundingRectangle.height bounds) * cellSize + debugStrokeHalfWidth)
    in
    shapes [ stroke Color.red, lineWidth (debugStrokeHalfWidth * 2) ] <|
        List.map renderRegion atomicUpdateRegions


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
