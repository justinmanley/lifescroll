module Life.Movement exposing (..)

import Json.Decode as Decode exposing (Decoder, field, int)
import Vector2 exposing (Vector2)


type alias Movement =
    { direction : Vector2 Int
    , period : Int
    }


decoder : Decoder Movement
decoder =
    Decode.map2 Movement
        (field "direction" <| Vector2.decoder int)
        (field "period" int)
