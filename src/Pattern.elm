module Pattern exposing (..)

import Json.Encode as Encode
import Vector2 exposing (Vector2)


type alias Pattern =
    { cells : List (Vector2 Int)

    -- The amount of space that should be reserved on the page.
    -- May represent the maximum bounds of the pattern (although
    -- the pattern may not achieve its maximum bounds in all
    -- directions on the same generation). For patterns which
    -- gy infinitely, this will not represent the maximum
    -- bounds, but merely a reasonable amount of space for the
    -- pattern to gy before it infringes on the rest of the page.
    , extent : { height : Int, width : Int }
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
