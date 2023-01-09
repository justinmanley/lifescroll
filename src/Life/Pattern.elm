module Life.Pattern exposing (..)

import Life.AtomicUpdateRegion exposing (AtomicUpdateRegion)
import Life.GridCells exposing (GridCells)
import Set


type alias Pattern =
    { cells : GridCells
    , atomicUpdateRegions : List AtomicUpdateRegion
    }


empty : Pattern
empty =
    { cells = Set.empty
    , atomicUpdateRegions = []
    }


setCells : Pattern -> GridCells -> Pattern
setCells pattern cells =
    { pattern | cells = cells }
