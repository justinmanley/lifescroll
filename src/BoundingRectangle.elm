module BoundingRectangle exposing (..)

import Json.Decode as Decode exposing (Decoder, field, float)


type alias BoundingRectangle =
    { top : Float
    , left : Float
    , bottom : Float
    , right : Float
    }


width : BoundingRectangle -> Float
width bounds =
    bounds.right - bounds.left


height : BoundingRectangle -> Float
height bounds =
    bounds.bottom - bounds.top


empty : BoundingRectangle
empty =
    { top = 0
    , left = 0
    , bottom = 0
    , right = 0
    }


decoder : Decoder BoundingRectangle
decoder =
    Decode.map4 BoundingRectangle
        (field "top" float)
        (field "left" float)
        (field "bottom" float)
        (field "right" float)
