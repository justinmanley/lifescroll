module Life.Pattern exposing (..)

import BoundingRectangle exposing (BoundingRectangle)
import Json.Encode as Encode exposing (int)
import Life.AtomicUpdateRegion as AtomicUpdateRegion exposing (AtomicUpdateRegion)
import Life.GridCells exposing (GridCells)
import Set
import Size2 exposing (Size2)


type alias Pattern =
    { cells : GridCells

    -- The amount of space that should be reserved on the page.
    -- May represent the maximum bounds of the pattern (although
    -- the pattern may not achieve its maximum bounds in all
    -- directions on the same generation). For patterns which
    -- go infinitely, this will not represent the maximum
    -- bounds, but merely a reasonable amount of space for the
    -- pattern to go before it infringes on the rest of the page.
    , reserved : BoundingRectangle Int
    , atomicUpdateRegion : AtomicUpdateRegion
    }


empty : Pattern
empty =
    { cells = Set.empty
    , reserved = BoundingRectangle.empty
    , atomicUpdateRegion = AtomicUpdateRegion.empty
    }


setReserved : Pattern -> Size2 Int -> Pattern
setReserved pattern size =
    { pattern
        | reserved =
            { top = 0
            , left = 0
            , bottom = size.height
            , right = size.width
            }
    }


setCells : Pattern -> GridCells -> Pattern
setCells pattern cells =
    { pattern | cells = cells }


verticalPadding : Int
verticalPadding =
    1


withVerticalPadding : Pattern -> Pattern
withVerticalPadding pattern =
    let
        extent =
            pattern.reserved
    in
    { pattern
        | reserved =
            { extent
                | top = extent.top - verticalPadding
            }
    }



-- Ignore cells for now because they are not needed.


encode : Pattern -> Encode.Value
encode { reserved } =
    Encode.object
        [ ( "extent"
          , BoundingRectangle.encode int reserved
          )
        ]
