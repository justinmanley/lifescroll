module Life exposing (..)

import Canvas exposing (Renderable, Shape, shapes)
import Canvas.Settings exposing (fill)
import Color
import Size2 exposing (Size2)
import Vector2 exposing (Vector2)


type alias LifeGrid =
    List (Vector2 Int)


empty : LifeGrid
empty =
    []


resize : Size2 Int -> Size2 Int -> LifeGrid -> LifeGrid
resize oldSize newSize grid =
    let
        toCenteredInNewGrid : Vector2 Int -> Vector2 Int
        toCenteredInNewGrid position =
            { x = position.x - floor (toFloat newSize.width / 2)
            , y = position.y - floor (toFloat newSize.height / 2)
            }

        fromCenteredInOldGrid : Vector2 Int -> Vector2 Int
        fromCenteredInOldGrid position =
            { x = position.x + floor (toFloat oldSize.width / 2)
            , y = position.y + floor (toFloat oldSize.height / 2)
            }

        oldIndexToNewIndex : Vector2 Int -> Vector2 Int
        oldIndexToNewIndex =
            fromCenteredInOldGrid >> toCenteredInNewGrid
    in
    if newSize.width == oldSize.width && newSize.height == oldSize.height then
        grid

    else
        List.map oldIndexToNewIndex grid


addPattern : List (Vector2 Int) -> LifeGrid -> LifeGrid
addPattern pattern grid =
    let
        withCell : Vector2 Int -> List (Vector2 Int) -> List (Vector2 Int)
        withCell cell cells =
            let
                cellEquals : Vector2 comparable -> Vector2 comparable -> Bool
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

        renderCell : Vector2 Int -> Shape
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
