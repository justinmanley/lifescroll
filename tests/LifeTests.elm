module LifeTests exposing (..)

import Expect
import Life exposing (addPattern)
import Test exposing (Test, describe, test)
import Vector2 exposing (Vector2)


testPattern : List (Vector2 Int)
testPattern =
    [ { x = 0, y = 0 }
    , { x = 1, y = 0 }
    ]


expectEqualLength : List a -> List b -> Expect.Expectation
expectEqualLength expected actual =
    Expect.equal (List.length expected) (List.length actual)


suite : Test
suite =
    describe "Life"
        [ test "inserts every cell in a pattern into an empty LifeGrid" <|
            \_ ->
                addPattern testPattern Life.empty
                    |> expectEqualLength testPattern
        ]
