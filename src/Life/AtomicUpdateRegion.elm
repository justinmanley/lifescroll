module Life.AtomicUpdateRegion exposing (..)

import BoundingRectangle exposing (BoundingRectangle, offsetBy)
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


moveBy : Movement -> Int -> BoundingRectangle Int -> BoundingRectangle Int
moveBy movement stepsElapsed bounds =
    if (stepsElapsed |> modBy movement.speed) == 0 then
        bounds |> offsetBy movement.direction

    else
        bounds


next : BoundingRectangle Int -> AtomicUpdateRegion -> AtomicUpdateRegion
next viewport region =
    if isSteppable viewport region then
        let
            stepsElapsed =
                region.stepsElapsed + 1
        in
        { region
            | bounds =
                case region.movement of
                    Just movement ->
                        region.bounds |> moveBy movement stepsElapsed

                    Nothing ->
                        region.bounds
            , stepsElapsed = stepsElapsed
        }

    else
        region
