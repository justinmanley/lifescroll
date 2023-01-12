module Life.Life exposing (..)

import BoundingRectangle exposing (BoundingRectangle, pointIsContainedIn)
import Canvas exposing (Renderable, Shape, shapes)
import Canvas.Settings exposing (fill)
import Canvas.Settings.Advanced exposing (transform, translate)
import Color
import Life.AtomicUpdateRegion.AtomicUpdateRegion exposing (AtomicUpdateRegion)
import Life.GridCells as GridCells exposing (GridCells)
import Life.Neighborhoods exposing (neighbors)
import Matrix
import Maybe exposing (withDefault)
import PageCoordinates
import Set
import Set.Extra as Set
import Vector2 exposing (Vector2, minus, x, y)


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


gridLineHalfWidth : number
gridLineHalfWidth =
    2


render : BoundingRectangle Float -> Float -> GridCells -> Renderable
render viewport cellSize cells =
    let
        square point size =
            Canvas.rect point size size

        renderCell : Vector2 Int -> Shape
        renderCell position =
            square
                ( toFloat (x position) * cellSize + gridLineHalfWidth
                , toFloat (y position) * cellSize
                )
                (cellSize - 2 * gridLineHalfWidth)

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
next cells =
    let
        bounds =
            GridCells.bounds cells
                |> withDefault (BoundingRectangle.empty 0)

        offset =
            ( bounds.left, bounds.top )

        normalize : Vector2 Int -> Vector2 Int
        normalize cell =
            cell |> minus offset

        denormalize : Vector2 Int -> Vector2 Int
        denormalize cell =
            Vector2.add cell offset
    in
    Set.map normalize cells
        |> nextNormalized
            (BoundingRectangle.width bounds)
            (BoundingRectangle.height bounds)
        |> Set.map denormalize


{-| Assumes all of its input cells are greater than (0, 0)
-}
nextNormalized : Int -> Int -> GridCells -> GridCells
nextNormalized width height cells =
    let
        matrix =
            Matrix.initialize
                width
                height
                (\cell -> Set.member cell cells)

        get : Int -> Int -> Maybe Bool
        get x y =
            if x < 0 || y < 0 then
                Nothing

            else
                Matrix.get x y matrix

        countLiveNeighbors : Vector2 Int -> Int
        countLiveNeighbors ( x, y ) =
            let
                neighborValues : List (Maybe Bool)
                neighborValues =
                    [ get (x - 1) (y - 1)
                    , get x (y - 1)
                    , get (x + 1) (y - 1)
                    , get (x + 1) y
                    , get (x + 1) (y + 1)
                    , get x (y + 1)
                    , get (x - 1) (y + 1)
                    , get (x - 1) y
                    ]
            in
            List.filterMap identity neighborValues
                |> List.filter identity
                |> List.length

        shouldBeBorn =
            Set.diff (Set.flatMap neighbors cells) cells
                |> Set.filter (countLiveNeighbors >> (\count -> count == 3))

        shouldSurvive =
            Set.filter (countLiveNeighbors >> (\count -> count == 3 || count == 2)) cells
    in
    Set.union shouldBeBorn shouldSurvive
