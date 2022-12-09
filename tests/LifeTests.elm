module LifeTests exposing (..)

import Expect
import GridPosition exposing (GridPosition)
import Life exposing (addPattern)
import Test exposing (Test, describe, test)


testPattern : List GridPosition
testPattern =
    [ { row = 0, col = 0 }
    , { row = 0, col = 1 }
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
                    |> (\{ cells } ->
                            cells
                       )
                    |> expectEqualLength testPattern
        ]
