module Life.AtomicUpdateRegion.BoundingRectangleEdgeMovements exposing (..)

import BoundingRectangle exposing (BoundingRectangle)
import Json.Decode as Decode exposing (Decoder, field, maybe)
import Life.AtomicUpdateRegion.EdgeMovement as EdgeMovement exposing (EdgeMovement)
import Maybe exposing (withDefault)


type alias BoundingRectangleEdgeMovements =
    BoundingRectangle (Maybe EdgeMovement)


moveEdges : Int -> BoundingRectangleEdgeMovements -> BoundingRectangle Int -> BoundingRectangle Int
moveEdges stepsElapsed edgeMovements bounds =
    let
        moveEdge : Int -> EdgeMovement -> Int
        moveEdge edge { period, direction } =
            if (stepsElapsed |> modBy period) == 0 then
                edge + direction

            else
                edge

        maybeMoveEdge : Int -> Maybe EdgeMovement -> Int
        maybeMoveEdge edge =
            Maybe.map (moveEdge edge) >> withDefault edge
    in
    BoundingRectangle.map2 maybeMoveEdge bounds edgeMovements


decoder : Decoder BoundingRectangleEdgeMovements
decoder =
    Decode.map4 BoundingRectangle
        (maybe <| field "top" EdgeMovement.decoder)
        (maybe <| field "left" EdgeMovement.decoder)
        (maybe <| field "bottom" EdgeMovement.decoder)
        (maybe <| field "right" EdgeMovement.decoder)
