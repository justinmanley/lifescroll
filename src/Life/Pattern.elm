module Life.Pattern exposing (..)

import Json.Encode as Encode
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
    , extent : Size2 Int
    , atomicUpdateRegion : AtomicUpdateRegion
    }


empty : Pattern
empty =
    { cells = Set.empty
    , extent =
        { width = 0
        , height = 0
        }
    , atomicUpdateRegion = AtomicUpdateRegion.empty
    }


setExtent : Pattern -> Size2 Int -> Pattern
setExtent pattern size =
    { pattern
        | extent = size
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
            pattern.extent
    in
    { pattern
        | extent =
            { extent
                | height = extent.height + verticalPadding -- at the top
            }
    }



-- Ignore cells for now because they are not needed.


encode : Pattern -> Encode.Value
encode { extent } =
    Encode.object
        [ ( "extent"
          , Encode.object
                [ ( "height", Encode.int extent.height )
                , ( "width", Encode.int extent.width )
                ]
          )
        ]
