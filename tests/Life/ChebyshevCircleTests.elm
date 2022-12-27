module Life.ChebyshevCircleTests exposing (..)

import Expect
import Fuzz exposing (intRange)
import Life.ChebyshevCircle exposing (chebyshevCircle)
import Set exposing (Set)
import Test exposing (Test, describe, fuzz, test)
import Vector2


suite : Test
suite =
    describe "ChebyshevCircle"
        [ fuzz (intRange 1 10) "does not contain the origin" <|
            \radius ->
                let
                    circle =
                        chebyshevCircle radius
                in
                if Set.member ( 0, 0 ) circle then
                    Expect.fail "Set contained the origin"

                else
                    Expect.pass
        , fuzz (intRange 1 10) "sum equals zero" <|
            \radius ->
                let
                    circle =
                        chebyshevCircle radius
                in
                Expect.equal (Set.foldl Vector2.add ( 0, 0 ) circle) ( 0, 0 )
        , test "chebyshev circle of radius 1 is equal to Moore neighborhood" <|
            \_ ->
                Expect.equalSets (chebyshevCircle 1) <|
                    Set.fromList
                        [ ( -1, -1 )
                        , ( -1, 0 )
                        , ( -1, 1 )
                        , ( 0, 1 )
                        , ( 1, 1 )
                        , ( 1, 0 )
                        , ( 1, -1 )
                        , ( 0, -1 )
                        ]
        , test "chebyshev circle of radius 2 is equal to the extended Moore neighborhood" <|
            \_ ->
                Expect.equalSets (chebyshevCircle 2) <|
                    Set.fromList
                        [ ( -2, -2 )
                        , ( -2, -1 )
                        , ( -2, 0 )
                        , ( -2, 1 )
                        , ( -2, 2 )
                        , ( -1, 2 )
                        , ( 0, 2 )
                        , ( 1, 2 )
                        , ( 2, 2 )
                        , ( 2, 1 )
                        , ( 2, 0 )
                        , ( 2, -1 )
                        , ( 2, -2 )
                        , ( 1, -2 )
                        , ( 0, -2 )
                        , ( -1, -2 )
                        ]
        ]
