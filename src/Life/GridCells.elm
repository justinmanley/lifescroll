module Life.GridCells exposing (..)

import BoundingRectangle exposing (BoundingRectangle)
import Set exposing (Set)
import Vector2 exposing (Vector2, x, y)


type alias GridCells =
    Set (Vector2 Int)


empty : GridCells
empty =
    Set.empty


bounds : GridCells -> Maybe (BoundingRectangle Int)
bounds cells =
    case Set.toList cells of
        [] ->
            Nothing

        _ ->
            Just
                { top = Set.foldl (y >> min) 0 cells
                , left = Set.foldl (x >> min) 0 cells
                , bottom = Set.foldl (y >> max) 0 cells + 1
                , right = Set.foldl (x >> max) 0 cells + 1
                }


toGrid : Float -> Float -> Int
toGrid cellSizeInPixels x =
    x / cellSizeInPixels |> floor
