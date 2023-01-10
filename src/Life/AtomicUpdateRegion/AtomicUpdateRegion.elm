module Life.AtomicUpdateRegion.AtomicUpdateRegion exposing (..)

import BoundingRectangle exposing (BoundingRectangle, offsetBy, vertical)
import Interval exposing (Interval, contains, hasIntersectionWith)
import Json.Decode as Decode exposing (Decoder, field, int, maybe, succeed)
import Life.AtomicUpdateRegion.Movement as Movement exposing (Movement)
import Life.AtomicUpdateRegion.StepCriterion as StepCriterion exposing (StepCriterion(..))


type alias AtomicUpdateRegion =
    -- Bounds x coordinates are relative to the leftmost live cell,
    -- while y coordinates are relative to the topmost live cell.
    { bounds : BoundingRectangle Int
    , movement : Maybe Movement
    , stepCriterion : StepCriterion
    , stepsElapsed : Int
    }


empty : AtomicUpdateRegion
empty =
    { bounds = BoundingRectangle.empty
    , movement = Nothing
    , stepCriterion = FullyContainedWithinSteppableRegion
    , stepsElapsed = 0
    }


isSteppable : Interval Int -> AtomicUpdateRegion -> Bool
isSteppable viewportVerticalBounds region =
    case region.stepCriterion of
        AnyIntersectionWithSteppableRegion ->
            vertical region.bounds |> hasIntersectionWith viewportVerticalBounds

        FullyContainedWithinSteppableRegion ->
            viewportVerticalBounds |> contains (vertical region.bounds)


moveBy : Movement -> Int -> BoundingRectangle Int -> BoundingRectangle Int
moveBy movement stepsElapsed boundingRectangle =
    if (stepsElapsed |> modBy movement.period) == 0 then
        boundingRectangle |> offsetBy movement.direction

    else
        boundingRectangle


next : AtomicUpdateRegion -> AtomicUpdateRegion
next region =
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


bounds : AtomicUpdateRegion -> BoundingRectangle Int
bounds region =
    region.bounds


decoder : Decoder AtomicUpdateRegion
decoder =
    Decode.map4 AtomicUpdateRegion
        (field "bounds" <| BoundingRectangle.decoder int)
        (maybe <| field "movement" Movement.decoder)
        (field "stepCriterion" StepCriterion.decoder)
        (succeed 0)
