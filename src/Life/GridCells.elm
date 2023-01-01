module Life.GridCells exposing (..)

import Set exposing (Set)
import Vector2 exposing (Vector2)


type alias GridCells =
    Set (Vector2 Int)


empty : GridCells
empty =
    Set.empty
