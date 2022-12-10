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
