module Vector2 exposing (..)

import Json.Decode as Decode exposing (Decoder, field)
import Tuple exposing (first, second)



-- Uses a tuple rather than a record type so that it can
-- be inserted into a Set.


type alias Vector2 number =
    ( number, number )


x : Vector2 number -> number
x =
    first


y : Vector2 number -> number
y =
    second


add : Vector2 number -> Vector2 number -> Vector2 number
add v1 v2 =
    ( x v1 + x v2, y v1 + y v2 )


subtract : Vector2 number -> Vector2 number -> Vector2 number
subtract v1 v2 =
    ( x v1 - x v2, y v1 - y v2 )


min : Vector2 number -> Vector2 number -> Vector2 number
min v1 v2 =
    ( Basics.min (x v1) (x v2), Basics.min (y v1) (y v2) )


map : (a -> b) -> Vector2 a -> Vector2 b
map f ( x1, y1 ) =
    ( f x1, f y1 )


fold : (a -> b -> c) -> Vector2 a -> Vector2 b -> Vector2 c
fold f ( x1, y1 ) ( x2, y2 ) =
    ( f x1 x2, f y1 y2 )


toString : Vector2 String -> String
toString ( a, b ) =
    "(" ++ a ++ ", " ++ b ++ ")"


decoder : Decoder number -> Decoder (Vector2 number)
decoder valueDecoder =
    Decode.map2 Tuple.pair
        (field "x" valueDecoder)
        (field "y" valueDecoder)
