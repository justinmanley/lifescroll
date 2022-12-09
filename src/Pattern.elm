module Pattern exposing (..)

import GridPosition exposing (GridPosition)
import Json.Encode as Encode


type alias Pattern =
    { cells : List GridPosition

    -- The amount of space that should be reserved on the page.
    -- May represent the maximum bounds of the pattern (although
    -- the pattern may not achieve its maximum bounds in all
    -- directions on the same generation). For patterns which
    -- grow infinitely, this will not represent the maximum
    -- bounds, but merely a reasonable amount of space for the
    -- pattern to grow before it infringes on the rest of the page.
    , extent : { rows : Int, columns : Int }
    }



-- Ignore cells for now because they are not needed.


encode : Pattern -> Encode.Value
encode { extent } =
    Encode.object
        [ ( "extent"
          , Encode.object
                [ ( "rows", Encode.int extent.rows )
                , ( "columns", Encode.int extent.columns )
                ]
          )
        ]
