module BoundingRectangle exposing (..)

import Canvas.Settings.Text exposing (TextBaseLine(..))
import Interval exposing (Interval)
import Json.Decode as Decode exposing (Decoder, field)
import Json.Encode as Encode exposing (Value)
import Vector2 exposing (Vector2)


type alias BoundingRectangle a =
    { top : a
    , left : a
    , bottom : a
    , right : a
    }


width : BoundingRectangle number -> number
width bounds =
    bounds.right - bounds.left


height : BoundingRectangle number -> number
height bounds =
    bounds.bottom - bounds.top


empty : a -> BoundingRectangle a
empty value =
    { top = value
    , left = value
    , bottom = value
    , right = value
    }


expand : Vector2 number -> BoundingRectangle number -> BoundingRectangle number
expand ( x, y ) { top, left, bottom, right } =
    { top = min y top
    , left = min x left
    , bottom = max y bottom
    , right = max x right
    }


containsPoint : Vector2 number -> BoundingRectangle number -> Bool
containsPoint ( x, y ) { top, left, bottom, right } =
    (left <= x && x <= right) && (top <= y && y <= bottom)


pointIsContainedIn : BoundingRectangle number -> Vector2 number -> Bool
pointIsContainedIn bounds cell =
    containsPoint cell bounds


union : BoundingRectangle number -> BoundingRectangle number -> BoundingRectangle number
union b1 b2 =
    { top = min b1.top b2.top
    , left = min b1.left b2.left
    , bottom = max b1.bottom b2.bottom
    , right = max b1.right b2.right
    }


intersect : BoundingRectangle number -> BoundingRectangle number -> BoundingRectangle number
intersect b1 b2 =
    { top = max b1.top b2.top
    , left = max b1.left b2.left
    , bottom = min b1.bottom b2.bottom
    , right = min b1.right b2.right
    }


area : BoundingRectangle number -> number
area bounds =
    width bounds * height bounds


offsetBy : Vector2 number -> BoundingRectangle number -> BoundingRectangle number
offsetBy ( x, y ) bounds =
    { top = y + bounds.top
    , left = x + bounds.left
    , bottom = y + bounds.bottom
    , right = x + bounds.right
    }


vertical : BoundingRectangle number -> Interval number
vertical { top, bottom } =
    { start = top
    , end = bottom
    }


horizontal : BoundingRectangle number -> Interval number
horizontal { left, right } =
    { start = left
    , end = right
    }


map : (a -> b) -> BoundingRectangle a -> BoundingRectangle b
map f { top, left, bottom, right } =
    { top = f top
    , left = f left
    , bottom = f bottom
    , right = f right
    }


map2 : (a -> b -> c) -> BoundingRectangle a -> BoundingRectangle b -> BoundingRectangle c
map2 f a b =
    { top = f a.top b.top
    , left = f a.left b.left
    , bottom = f a.bottom b.bottom
    , right = f a.right b.right
    }


decoder : Decoder number -> Decoder (BoundingRectangle number)
decoder valueDecoder =
    Decode.map4 BoundingRectangle
        (field "top" valueDecoder)
        (field "left" valueDecoder)
        (field "bottom" valueDecoder)
        (field "right" valueDecoder)


encode : (number -> Value) -> BoundingRectangle number -> Value
encode encodeNumber { top, left, bottom, right } =
    Encode.object
        [ ( "top", encodeNumber top )
        , ( "left", encodeNumber left )
        , ( "bottom", encodeNumber bottom )
        , ( "right", encodeNumber right )
        ]
