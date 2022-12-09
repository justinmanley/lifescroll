module Life exposing (..)

import Canvas exposing (Renderable, Shape, shapes)
import Canvas.Settings exposing (fill)
import Color
import GridPosition exposing (GridPosition)
import Page exposing (Page)
import PatternAnchor exposing (PagePatternAnchor, PatternAnchor)


type alias LifeGrid =
    { width : Int
    , height : Int
    , cells : List GridPosition
    }


empty : LifeGrid
empty =
    { width = 0
    , height = 0
    , cells = []
    }


resize : Int -> Int -> LifeGrid -> LifeGrid
resize newWidth newHeight grid =
    let
        toCenteredInNewGrid : GridPosition -> GridPosition
        toCenteredInNewGrid position =
            { row = position.row - floor (toFloat newHeight / 2)
            , col = position.col - floor (toFloat newWidth / 2)
            }

        fromCenteredInOldGrid : GridPosition -> GridPosition
        fromCenteredInOldGrid position =
            { row = position.row + floor (toFloat grid.height / 2)
            , col = position.col + floor (toFloat grid.width / 2)
            }

        oldIndexToNewIndex : GridPosition -> GridPosition
        oldIndexToNewIndex =
            fromCenteredInOldGrid >> toCenteredInNewGrid
    in
    if newWidth == grid.width && newHeight == grid.height then
        grid

    else
        { width = newWidth
        , height = newHeight
        , cells = List.map oldIndexToNewIndex grid.cells
        }


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
    { grid | cells = List.foldl withCell grid.cells pattern }


render : Float -> LifeGrid -> Renderable
render cellSize { cells } =
    let
        square point size =
            Canvas.rect point size size

        renderCell : GridPosition -> Shape
        renderCell position =
            let
                { row, col } =
                    position
            in
            square ( toFloat col * cellSize, toFloat row * cellSize ) cellSize
    in
    shapes [ fill Color.black ] <| List.map renderCell cells


next : LifeGrid -> LifeGrid
next =
    -- TODO: implement.
    identity
