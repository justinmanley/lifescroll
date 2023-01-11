module Life.AtomicUpdateRegion.Movement2 exposing (..)

import Json.Decode as Decode exposing (Decoder, field, int)
import Life.AtomicUpdateRegion.Movement exposing (Movement)
import Vector2 exposing (Vector2)


type alias Movement2 =
    Movement (Vector2 Int)


decoder : Decoder Movement2
decoder =
    Decode.map2 Movement
        (field "direction" <| Vector2.decoder int)
        (field "period" int)
