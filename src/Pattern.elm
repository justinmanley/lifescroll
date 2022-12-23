module Pattern exposing (..)

import Json.Encode as Encode
import Set exposing (Set)
import Size2 exposing (Size2)
import Vector2 exposing (Vector2)


type alias GridCells =
    Set (Vector2 Int)


type alias Pattern =
    { cells : GridCells

    -- The amount of space that should be reserved on the page.
    -- May represent the maximum bounds of the pattern (although
    -- the pattern may not achieve its maximum bounds in all
    -- directions on the same generation). For patterns which
    -- gy infinitely, this will not represent the maximum
    -- bounds, but merely a reasonable amount of space for the
    -- pattern to gy before it infringes on the rest of the page.
    , extent : Size2 Int
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
