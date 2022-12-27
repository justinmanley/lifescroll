module ConnectedComponentTests exposing (..)

import ConnectedComponent exposing (connectedComponents)
import Expect
import Fuzz exposing (intRange)
import List.Extra exposing (lift2)
import Pattern exposing (GridCells)
import Set
import Test exposing (Test, describe, fuzz2, test)
import Vector2 exposing (Vector2)


cartesianProduct : List number -> List number -> List (Vector2 number)
cartesianProduct =
    lift2 Tuple.pair



-- Makes a grid like:
--   x  x  x
--
--   x  x  x
--
--   x  x  x
-- Or:
--   xxx
--   xxx
--   xxx


stridedGrid : Int -> Int -> Int -> GridCells
stridedGrid stride width height =
    Set.fromList <|
        cartesianProduct
            (List.map ((*) stride) <| List.range 0 (width - 1))
            (List.map ((*) stride) <| List.range 0 (height - 1))



-- Makes a set of dashes like:
--   xxx xxx xxx
-- or:
--   xxxx   xxxx   xxxx   xxxx


dashes : Int -> Int -> Int -> GridCells
dashes stride length num =
    let
        -- Subtract 1 from stride to make it match effect of the stridedGrid parameter.
        dashStart : Int -> Int
        dashStart index =
            (length + (stride - 1)) * index

        dash : Int -> List Int
        dash index =
            List.map ((+) (dashStart index)) <| List.range 0 (length - 1)
    in
    Set.fromList <|
        List.map (\i -> ( i, 0 )) <|
            List.concatMap dash (List.range 0 (num - 1))


suite : Test
suite =
    describe "ConnectedComponent"
        [ describe "connectedComponents"
            [ fuzz2 (intRange 1 10) (intRange 1 10) "a solid rectangle of cells is a single connected component" <|
                \width height ->
                    Expect.equal (List.length (connectedComponents (stridedGrid 1 width height))) 1
            , fuzz2 (intRange 1 10) (intRange 1 10) "a grid with one empty cell between every live cell is a single connected component" <|
                \width height ->
                    Expect.equal (List.length (connectedComponents (stridedGrid 2 width height))) 1
            , fuzz2 (intRange 1 10) (intRange 1 10) "a grid with two empty cells between every live cell is w×h connected components" <|
                \width height ->
                    Expect.equal (List.length (connectedComponents (stridedGrid 3 width height))) (width * height)
            , fuzz2 (intRange 1 10) (intRange 1 10) "an uninterrupted row of live cells is a single connected component" <|
                \length num ->
                    Expect.equal (List.length (connectedComponents (dashes 1 length num))) 1
            , fuzz2 (intRange 1 10) (intRange 1 10) "a row of alternating live and dead cells is a single connected component" <|
                \length num ->
                    Expect.equal (List.length (connectedComponents (dashes 2 length num))) 1
            , fuzz2 (intRange 1 10) (intRange 1 10) "a row with two dead cells between every uninterrupted sequence of live cells is multiple connected components" <|
                \length num ->
                    Expect.equal (List.length (connectedComponents (dashes 3 length num))) num
            ]
        ]
