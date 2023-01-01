module Life.ProtectedRegion exposing (..)

import BoundingRectangle exposing (BoundingRectangle)
import Vector2 exposing (Vector2)


type alias Movement =
    { direction : Vector2 Int
    , speed : Int
    }



-- TODO: Instead of 'protected', consider 'atomic,' meaning that
-- everything in the region must be updated, or nothing.


type alias ProtectedRegion =
    { bounds : BoundingRectangle Int
    , movement : Maybe Movement
    }
