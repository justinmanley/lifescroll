module Life.AtomicUpdateRegion exposing (..)

import BoundingRectangle exposing (BoundingRectangle, offsetBy, vertical)
import Interval exposing (Interval, contains)
import Json.Decode as Decode exposing (Decoder, field, int, maybe, succeed)
import Life.Movement as Movement exposing (Movement)


type alias AtomicUpdateRegion =
    -- Bounds x coordinates are relative to the leftmost live cell,
    -- while y coordinates are relative to the topmost live cell.
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


isSteppable : Interval Int -> AtomicUpdateRegion -> Bool
isSteppable viewportVerticalBounds { bounds } =
    viewportVerticalBounds
        |> contains (vertical bounds)


moveBy : Movement -> Int -> BoundingRectangle Int -> BoundingRectangle Int
moveBy movement stepsElapsed bounds =
    if (stepsElapsed |> modBy movement.period) == 0 then
        bounds |> offsetBy movement.direction

    else
        bounds


next : Interval Int -> AtomicUpdateRegion -> AtomicUpdateRegion
next viewportVerticalBounds region =
    if isSteppable viewportVerticalBounds region then
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


decoder : Decoder AtomicUpdateRegion
decoder =
    Decode.map3 AtomicUpdateRegion
        (field "bounds" <| BoundingRectangle.decoder int)
        (maybe <| field "movement" Movement.decoder)
        (succeed 0)
