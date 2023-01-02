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
    , stepsElapsed : Int
    }


empty : ProtectedRegion
empty =
    { bounds = BoundingRectangle.empty
    , movement = Nothing
    , stepsElapsed = 0
    }


isSteppable : BoundingRectangle Int -> ProtectedRegion -> Bool
isSteppable viewport region =
    BoundingRectangle.contains viewport region.bounds


stepIfEligible : BoundingRectangle Int -> Int -> ProtectedRegion -> ProtectedRegion
stepIfEligible viewport numSteps region =
    if isSteppable viewport region then
        { region | stepsElapsed = region.stepsElapsed + numSteps }

    else
        region
