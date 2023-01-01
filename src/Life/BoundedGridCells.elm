module Life.BoundedGridCells exposing (..)

import BoundingRectangle exposing (BoundingRectangle)
import Life.GridCells exposing (GridCells)


type alias BoundedGridCells =
    { cells : GridCells
    , bounds : BoundingRectangle Int
    }
