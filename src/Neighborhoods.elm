module Neighborhoods exposing (..)

import ChebyshevCircle exposing (chebyshevCircle)
import Set exposing (Set)
import Vector2 exposing (Vector2)


neighbors : Vector2 Int -> Set (Vector2 Int)
neighbors cell =
    Set.map (Vector2.add cell) (chebyshevCircle 1)


extendedNeighbors : Vector2 Int -> Set (Vector2 Int)
extendedNeighbors cell =
    Set.map (Vector2.add cell) (chebyshevCircle 2)
