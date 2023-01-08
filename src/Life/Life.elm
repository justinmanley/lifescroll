module Life.Life exposing (..)

import BoundingRectangle exposing (BoundingRectangle, pointIsContainedIn)
import Canvas exposing (Renderable, Shape, shapes)
import Canvas.Settings exposing (fill)
import Canvas.Settings.Advanced exposing (transform, translate)
import Color
import Life.AtomicUpdateRegion exposing (AtomicUpdateRegion)
import Life.GridCells as GridCells exposing (GridCells)
import Life.Neighborhoods exposing (neighbors)
import PageCoordinates
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


toggleCell : Vector2 Int -> GridCells -> GridCells
toggleCell position grid =
    if Set.member position grid then
        Set.remove position grid

    else
        Set.insert position grid


render : BoundingRectangle Float -> Float -> GridCells -> Renderable
render viewport cellSize cells =
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

        gridViewport =
            PageCoordinates.toGrid cellSize viewport
    in
    shapes
        [ fill Color.black
        , transform [ translate -viewport.left -viewport.top ]
        ]
    <|
        List.map renderCell <|
            List.filter (pointIsContainedIn gridViewport) <|
                Set.toList cells


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
