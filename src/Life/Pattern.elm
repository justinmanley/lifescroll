module Life.Pattern exposing (..)

import Life.AtomicUpdateRegion as AtomicUpdateRegion exposing (AtomicUpdateRegion)
import Life.GridCells exposing (GridCells)
import Set


type alias Pattern =
    { cells : GridCells

    -- In absolute coordinates with respect to the grid origin.
    , atomicUpdateRegion : AtomicUpdateRegion
    }


empty : Pattern
empty =
    { cells = Set.empty
    , atomicUpdateRegion = AtomicUpdateRegion.empty
    }


setCells : Pattern -> GridCells -> Pattern
setCells pattern cells =
    { pattern | cells = cells }


verticalPadding : number
verticalPadding =
    1
