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
        cell :: rest ->
            Just
                { top = List.foldl (y >> min) (y cell) rest
                , left = List.foldl (x >> min) (x cell) rest
                , bottom = List.foldl (y >> max) (y cell) rest + 1
                , right = List.foldl (x >> max) (x cell) rest + 1
                }

        _ ->
            Nothing
