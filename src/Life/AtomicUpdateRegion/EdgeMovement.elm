module Life.AtomicUpdateRegion.EdgeMovement exposing (..)

import Json.Decode as Decode exposing (Decoder, field, int)
import Life.AtomicUpdateRegion.Movement exposing (Movement)


type alias EdgeMovement =
    Movement Int


decoder : Decoder EdgeMovement
decoder =
    Decode.map2 Movement
        (field "direction" int)
        (field "period" int)
