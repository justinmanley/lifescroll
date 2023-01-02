module Life.AtomicUpdateRegionTests exposing (..)

import Expect
import Life.AtomicUpdateRegion exposing (moveBy)
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "AtomicUpdateRegion"
        [ describe "moveBy"
            [ test "moves the bounding box by the appropriate amount" <|
                \_ ->
                    let
                        stepsElapsed =
                            3

                        movement =
                            { direction = ( -1, 1 )
                            , speed = 3
                            }

                        bounds =
                            { top = 100
                            , left = 100
                            , bottom = 101
                            , right = 101
                            }
                    in
                    Expect.equal
                        (moveBy movement stepsElapsed bounds)
                        { top = 101
                        , left = 99
                        , bottom = 102
                        , right = 100
                        }
            ]
        ]
