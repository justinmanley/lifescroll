module Life.Life exposing (..)

import BoundingRectangle exposing (BoundingRectangle)
import Canvas exposing (Renderable, Shape, shapes)
import Canvas.Settings exposing (fill)
import Color
import Life.ConnectedComponent exposing (ConnectedComponent, connectedComponents)
import Life.Neighborhoods exposing (neighbors)
import Life.Pattern exposing (GridCells)
import Set exposing (Set)
import Set.Extra as Set
import Size2 exposing (Size2)
import Vector2 exposing (Vector2, x, y)


empty : GridCells
empty =
    Set.empty


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


insertPattern : Set (Vector2 Int) -> GridCells -> GridCells
insertPattern pattern grid =
    let
        insertWithConflictLogging : Vector2 Int -> Set (Vector2 Int) -> Set (Vector2 Int)
        insertWithConflictLogging cell cells =
            if Set.member cell cells then
                Debug.log "found a conflict while attempting to insert pattern" cells

            else
                Set.insert cell cells
    in
    Set.foldl insertWithConflictLogging grid pattern


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


nextInViewport : BoundingRectangle Int -> GridCells -> GridCells
nextInViewport viewport life =
    let
        -- Dividing the Life grid into connected components and
        -- applying the rules to entire components ensures that
        -- patterns do not get corrupted as they cross over into
        -- the viewport, with the part of the pattern within the
        -- viewport being evolved forward while the rest of the
        -- pattern remains static.
        nextComponent : ConnectedComponent -> GridCells
        nextComponent component =
            if BoundingRectangle.contains viewport component.bounds then
                next component.cells

            else
                component.cells
    in
    List.foldl Set.union Set.empty (List.map nextComponent (connectedComponents life))


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
