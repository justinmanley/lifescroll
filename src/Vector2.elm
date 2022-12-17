module Vector2 exposing (..)

import Tuple exposing (first, second)



-- Uses a tuple rather than a record type so that it can
-- be inserted into a Set.


type alias Vector2 a =
    ( a, a )


x : Vector2 a -> a
x =
    first


y : Vector2 a -> a
y =
    second


map : (a -> b) -> Vector2 a -> Vector2 b
map f ( x1, y1 ) =
    ( f x1, f y1 )


fold : (a -> b -> c) -> Vector2 a -> Vector2 b -> Vector2 c
fold f ( x1, y1 ) ( x2, y2 ) =
    ( f x1 x2, f y1 y2 )


toString : Vector2 String -> String
toString ( a, b ) =
    "(" ++ a ++ ", " ++ b ++ ")"
