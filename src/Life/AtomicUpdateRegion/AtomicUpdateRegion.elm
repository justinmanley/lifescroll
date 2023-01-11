module Life.AtomicUpdateRegion.AtomicUpdateRegion exposing (..)

import BoundingRectangle exposing (BoundingRectangle, offsetBy, vertical)
import Interval exposing (Interval, contains, hasIntersectionWith)
import Json.Decode as Decode exposing (Decoder, field, int, maybe, succeed)
import Life.AtomicUpdateRegion.BoundingRectangleEdgeMovements as BoundingRectangleEdgeMovements exposing (BoundingRectangleEdgeMovements, moveEdges)
import Life.AtomicUpdateRegion.Movement2 as Movement exposing (Movement2)
import Life.AtomicUpdateRegion.StepCriterion as StepCriterion exposing (StepCriterion(..))
import Maybe exposing (withDefault)


type alias AtomicUpdateRegion =
    -- Bounds x coordinates are relative to the leftmost live cell,
    -- while y coordinates are relative to the topmost live cell.
    { bounds : BoundingRectangle Int
    , movement : Maybe Movement2
    , boundsEdgeMovements : BoundingRectangleEdgeMovements
    , stepCriterion : StepCriterion
    , stepsElapsed : Int
    }


empty : AtomicUpdateRegion
empty =
    { bounds = BoundingRectangle.empty 0
    , boundsEdgeMovements = BoundingRectangle.empty Nothing
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


moveBy : Movement2 -> Int -> BoundingRectangle Int -> BoundingRectangle Int
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
            moveBounds region.movement stepsElapsed region.bounds
                |> moveEdges stepsElapsed region.boundsEdgeMovements
        , stepsElapsed = stepsElapsed
    }


moveBounds : Maybe Movement2 -> Int -> BoundingRectangle Int -> BoundingRectangle Int
moveBounds maybeMovement stepsElapsed boundingRectangle =
    case maybeMovement of
        Just movement ->
            boundingRectangle |> moveBy movement stepsElapsed

        Nothing ->
            boundingRectangle


bounds : AtomicUpdateRegion -> BoundingRectangle Int
bounds region =
    region.bounds


decoder : Decoder AtomicUpdateRegion
decoder =
    let
        maybeWithDefault : a -> Decoder a -> Decoder a
        maybeWithDefault defaultValue d =
            d |> maybe |> Decode.map (withDefault defaultValue)
    in
    Decode.map5 AtomicUpdateRegion
        (field "bounds" <| BoundingRectangle.decoder int)
        (maybe <| field "movement" Movement.decoder)
        (maybeWithDefault (BoundingRectangle.empty Nothing) <|
            field "boundsEdgeMovements" BoundingRectangleEdgeMovements.decoder
        )
        (field "stepCriterion" StepCriterion.decoder)
        (succeed 0)
