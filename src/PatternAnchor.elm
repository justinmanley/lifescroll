module PatternAnchor exposing (..)

import BoundingRectangle exposing (BoundingRectangle)
import Json.Decode as Decode exposing (Decoder, field, string)


type alias PatternAnchor =
    { id : String
    , bounds : BoundingRectangle Float
    }


decoder : Decoder PatternAnchor
decoder =
    Decode.map2 PatternAnchor
        (field "id" string)
        (field "bounds" BoundingRectangle.decoder)
