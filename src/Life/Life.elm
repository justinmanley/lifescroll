module Life.Life exposing (..)

import Canvas exposing (Renderable, Shape, shapes)
import Canvas.Settings exposing (fill)
import Color
import Life.BoundedGridCells exposing (BoundedGridCells)
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


insertPattern : BoundedGridCells -> LifeGrid -> LifeGrid
insertPattern pattern { cells, protected } =
    let
        insertWithConflictLogging : Vector2 Int -> GridCells -> GridCells
        insertWithConflictLogging cell allCells =
            if Set.member cell allCells then
                Debug.log "found a conflict while attempting to insert pattern" allCells

            else
                Set.insert cell allCells
    in
    { cells = Set.foldl insertWithConflictLogging cells pattern.cells
    , protected =
        { bounds = pattern.bounds
        , movement = Nothing
        , stepsElapsed = 0
        }
            :: protected
    }



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
