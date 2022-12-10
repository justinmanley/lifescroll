module LifeTests exposing (..)

import Expect
import Life exposing (addPattern)
import Set exposing (Set)
import Test exposing (Test, describe, test)
import Vector2 exposing (Vector2)


testPattern : Set (Vector2 Int)
testPattern =
    Set.fromList
        [ ( 0, 0 )
        , ( 1, 0 )
        ]


expectEqualSize : Set a -> Set b -> Expect.Expectation
expectEqualSize expected actual =
    Expect.equal (Set.size expected) (Set.size actual)


suite : Test
suite =
    describe "Life"
        [ test "inserts every cell in a pattern into an empty LifeGrid" <|
            \_ ->
                addPattern testPattern Life.empty
                    |> expectEqualSize testPattern
        ]
