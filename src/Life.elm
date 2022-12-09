module Life exposing (..)

import Canvas exposing (Renderable, Shape, shapes)
import Canvas.Settings exposing (fill)
import Color
import GridPosition exposing (GridPosition)
import Size2 exposing (Size2)


type alias LifeGrid =
    List GridPosition


empty : LifeGrid
empty =
    []


resize : Size2 Int -> Size2 Int -> LifeGrid -> LifeGrid
resize oldSize newSize grid =
    let
        toCenteredInNewGrid : GridPosition -> GridPosition
        toCenteredInNewGrid position =
            { x = position.x - floor (toFloat newSize.width / 2)
            , y = position.y - floor (toFloat newSize.height / 2)
            }

        fromCenteredInOldGrid : GridPosition -> GridPosition
        fromCenteredInOldGrid position =
            { x = position.x + floor (toFloat oldSize.width / 2)
            , y = position.y + floor (toFloat oldSize.height / 2)
            }

        oldIndexToNewIndex : GridPosition -> GridPosition
        oldIndexToNewIndex =
            fromCenteredInOldGrid >> toCenteredInNewGrid
    in
    if newSize.width == oldSize.width && newSize.height == oldSize.height then
        grid

    else
        List.map oldIndexToNewIndex grid


addPattern : List GridPosition -> LifeGrid -> LifeGrid
addPattern pattern grid =
    let
        withCell : GridPosition -> List GridPosition -> List GridPosition
        withCell cell cells =
            let
                cellEquals : GridPosition -> GridPosition -> Bool
                cellEquals c1 c2 =
                    if c1 == c2 then
                        Debug.log "found a conflict while attempting to insert pattern" True

                    else
                        False
            in
            if List.any (cellEquals cell) cells then
                cells

            else
                cell :: cells
    in
    List.foldl withCell grid pattern


render : Float -> LifeGrid -> Renderable
render cellSize cells =
    let
        square point size =
            Canvas.rect point size size

        renderCell : GridPosition -> Shape
        renderCell position =
            let
                { y, x } =
                    position
            in
            square ( toFloat x * cellSize, toFloat y * cellSize ) cellSize
    in
    shapes [ fill Color.black ] <| List.map renderCell cells


next : LifeGrid -> LifeGrid
next =
    -- TODO: implement.
    identity
