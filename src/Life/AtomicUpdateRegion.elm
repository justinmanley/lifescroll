module Life.AtomicUpdateRegion exposing (..)

import BoundingRectangle exposing (BoundingRectangle)
import Vector2 exposing (Vector2)


type alias Movement =
    { direction : Vector2 Int
    , speed : Int
    }


type alias AtomicUpdateRegion =
    { bounds : BoundingRectangle Int
    , movement : Maybe Movement
    , stepsElapsed : Int
    }


empty : AtomicUpdateRegion
empty =
    { bounds = BoundingRectangle.empty
    , movement = Nothing
    , stepsElapsed = 0
    }


isSteppable : BoundingRectangle Int -> AtomicUpdateRegion -> Bool
isSteppable viewport region =
    BoundingRectangle.contains viewport region.bounds


stepIfEligible : BoundingRectangle Int -> Int -> AtomicUpdateRegion -> AtomicUpdateRegion
stepIfEligible viewport numSteps region =
    if isSteppable viewport region then
        { region | stepsElapsed = region.stepsElapsed + numSteps }

    else
        region
