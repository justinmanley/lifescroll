module Life exposing (..)

import Canvas exposing (Renderable, Shape, shapes)
import Canvas.Settings exposing (fill)
import Color
import Dict exposing (Dict)
import Page exposing (Page)
import PatternAnchor exposing (PagePatternAnchor, PatternAnchor)


type alias GridPosition =
    { row : Int
    , col : Int
    }


type alias Pattern =
    List GridPosition


type alias PatternDict =
    Dict String Pattern


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


type alias GridPatternAnchor =
    PatternAnchor Int


positionInGrid : Page -> PagePatternAnchor -> GridPatternAnchor
positionInGrid page pattern =
    let
        row =
            0

        col =
            0
    in
    { id = pattern.id
    , side = pattern.side -- no longer necessary, but that's ok
    , position = ( row, col )
    }


addPattern : Pattern -> LifeGrid -> LifeGrid
addPattern pattern grid =
    let
        withCell : GridPosition -> List GridPosition -> List GridPosition
        withCell cell cells =
            let
                cellEquals : GridPosition -> GridPosition -> Bool
                cellEquals c1 c2 =
                    if c1 == c2 then
                        Debug.log "found a conflict while attempting to insert pattern" False

                    else
                        True
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
            square ( toFloat row * cellSize, toFloat col * cellSize ) cellSize
    in
    shapes [ fill Color.black ] <| List.map renderCell cells
