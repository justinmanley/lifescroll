module BoundingRectangle exposing (..)

import Json.Decode as Decode exposing (Decoder, field, float)


type alias BoundingRectangle number =
    { top : number
    , left : number
    , bottom : number
    , right : number
    }


width : BoundingRectangle number -> number
width bounds =
    bounds.right - bounds.left


height : BoundingRectangle number -> number
height bounds =
    bounds.bottom - bounds.top


empty : BoundingRectangle number
empty =
    { top = 0
    , left = 0
    , bottom = 0
    , right = 0
    }


contains : BoundingRectangle number -> BoundingRectangle number -> Bool
contains b1 b2 =
    True


decoder : Decoder (BoundingRectangle Float)
decoder =
    Decode.map4 BoundingRectangle
        (field "top" float)
        (field "left" float)
        (field "bottom" float)
        (field "right" float)
